import AsyncUtils
import Combine

public final class CameraHubServer: StateServicePort {
  public typealias Event = CameraHubServerEvent
  public typealias Command = CameraHubServerCommand
  private let actor: CameraHubServerActor
  nonisolated(unsafe) let state$: CurrentValueSubject<CameraHubServerState, any Error> =
    CurrentValueSubject<CameraHubServerState, any Error>(.init())
  nonisolated(unsafe) let event$ = PassthroughSubject<CameraHubServerEvent, any Error>()
  nonisolated(unsafe) let error$ = PassthroughSubject<Error, Never>()
  private nonisolated(unsafe) var pipes: [StreamPipe] = []
  public var state: CameraHubServerState { state$.value }
  public var onState: any Publisher<CameraHubServerState, any Error> { state$ }
  public var onEvent: any Publisher<CameraHubServerEvent, any Error> { event$ }
  public var onError: any Publisher<Error, Never> { error$ }

  public init(
    localHub: some CameraHubServicePort,
    advertiserFactory: some CameraHubAdvertiserFactoryPort
  ) async {
    let actor = await CameraHubServerActor(
      localHub: localHub,
      advertiserFactory: advertiserFactory
    )
    self.actor = actor
    pipes = await withTaskGroup(of: StreamPipe.self) { taskGroup in
      taskGroup.addTask {
        AsyncThrowingStreamToSubjectPipe(stream: await actor.stateStream, subject: self.state$)
      }
      taskGroup.addTask {
        AsyncThrowingStreamToSubjectPipe(stream: await actor.eventStream, subject: self.event$)
      }
      taskGroup.addTask {
        AsyncStreamToSubjectPipe(stream: await actor.errorStream, subject: self.error$)
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
