import Combine

public final class CameraHubServer: StateServicePort {
  public typealias Event = CameraHubServerEvent
  public typealias Command = CameraHubServerCommand
  private let actor: CameraHubServerActor
  nonisolated(unsafe) let state$ = CurrentValueSubject<CameraHubServerState, any Error>(.init())
  nonisolated(unsafe) let event$ = PassthroughSubject<CameraHubServerEvent, any Error>()
  nonisolated(unsafe) var tasks: [Task<Void, any Error>] = []
  public var state: CameraHubServerState {
    state$.value
  }
  public var onState: any Publisher<CameraHubServerState, any Error> {
    state$
  }
  public var onEvent: any Publisher<CameraHubServerEvent, any Error> {
    event$
  }

  public init(
    localHub: some CameraHubServicePort,
    advertiserFactory: some CameraHubAdvertiserFactoryPort
  ) async {
    actor = await .init(
      localHub: localHub,
      advertiserFactory: advertiserFactory
    )

    let tasks = [
      Task { [weak self] in
        guard let self = self else { return }
        for try await state in await actor.stateSequence! {
          if Task.isCancelled { break }
          state$.send(state)
        }
      },
      Task { [weak self] in
        guard let self = self else { return }
        for try await state in await actor.eventSequence! {
          if Task.isCancelled { break }
          event$.send(state)
        }
      },
    ]
    self.tasks = tasks
  }

  deinit {
    tasks.forEach { $0.cancel() }
  }

  public func perform(_ command: CameraHubServerCommand) async throws {
    try await actor.perform(command)
  }
}
