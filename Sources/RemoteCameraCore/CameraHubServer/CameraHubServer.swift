import Combine

public final class CameraHubServer: StateServicePort {
  public typealias Event = CameraHubServerEvent
  public typealias Command = CameraHubCommands

  final let localHub: any CameraHubServicePort
  final let advertiserFactory: any CameraHubAdvertiserFactoryPort
  nonisolated(unsafe) let state$ = CurrentValueSubject<CameraHubServerState, any Error>(.init())
  nonisolated(unsafe) let event$ = PassthroughSubject<CameraHubServerEvent, any Error>()
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
  ) {
    self.localHub = localHub
    self.advertiserFactory = advertiserFactory
  }

  public func perform(_ command: CameraHubCommands) async throws {

  }
}
