import AsyncUtils
@preconcurrency import Combine

public final class CameraHubServer: StateServicePort {
  public typealias Event = CameraHubServerEvent
  public typealias Command = CameraHubServerCommand

  private let actor: CameraHubServerActor
  private let state$: CurrentValueSubject<CameraHubServerState, Never>
  private let pipes: [StreamPipe]
  public let onStatus: AnyPublisher<NodeStatus, Never>
  public var state: CameraHubServerState { state$.value }
  public let onState: AnyPublisher<CameraHubServerState, Never>
  public let onEvent: AnyPublisher<CameraHubServerEvent, Never>
  public let onError: AnyPublisher<Error, Never>
  public init(
    localHub: some CameraHubServicePort,
    advertiserFactory: some CameraHubAdvertiserFactoryPort
  ) async {
    let status$ =
      CurrentValueSubject<NodeStatus, Never>(.preparing)
    let state$ = CurrentValueSubject<CameraHubServerState, Never>(.init())
    let event$ = PassthroughSubject<CameraHubServerEvent, Never>()
    let error$ = PassthroughSubject<Error, Never>()
    self.state$ = state$
    onState = state$.eraseToAnyPublisher()
    onStatus = status$.eraseToAnyPublisher()
    onEvent = event$.eraseToAnyPublisher()
    onError = error$.eraseToAnyPublisher()
    let actor = await CameraHubServerActor(
      localHub: localHub,
      advertiserFactory: advertiserFactory
    )
    self.actor = actor
    pipes = await withTaskGroup(of: StreamPipe.self) { taskGroup in
      taskGroup.addTask {
        PublisherToSubjectPipe(publisher: await actor.onStatus, subject: status$)
      }
      taskGroup.addTask {
        PublisherToSubjectPipe(publisher: await actor.onState, subject: state$)
      }
      taskGroup.addTask {
        PublisherToSubjectPipe(publisher: await actor.onEvent, subject: event$)
      }
      taskGroup.addTask {
        PublisherToSubjectPipe(publisher: await actor.onError, subject: error$)
      }
      return await taskGroup.reduce(into: [StreamPipe]()) { pipes, pipe in
        pipes.append(pipe)
      }
    }
  }

  public func perform(_ command: CameraHubServerCommand) async throws {
    try await actor.perform(command)
  }
}
