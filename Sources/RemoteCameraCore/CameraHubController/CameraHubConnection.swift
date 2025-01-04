import CameraCore
import Combine

public actor CameraHubConnection {
  let hub: CameraHubServicePort
  let controller: RemoteCameraHubControllerPort
  private nonisolated(unsafe) var bag = Set<AnyCancellable>()

  init(hub: CameraHubServicePort, controller: RemoteCameraHubControllerPort) {
    self.hub = hub
    self.controller = controller
    controller.onCommand.sink { [weak self] command in
      Task { [weak self] in
        await self?.routeCommand(command)
      }
    }.store(in: &bag)
    hub.onEvent.sink { [weak self] completion in
      Task { [weak self] in
        await self?.handleHubEventCompletion(completion)
      }
    } receiveValue: { [weak self] event in
      Task { [weak self] in
        await self?.routeEvent(event)
      }
    }.store(in: &bag)
    hub.onState.sink { [weak self] completion in
      Task { [weak self] in
        await self?.handleHubStateCompletion(completion)
      }
    } receiveValue: { [weak self] state in
      Task { [weak self] in
        await self?.updateState(state)
      }
    }.store(in: &bag)
  }
}

extension CameraHubConnection {
  public enum ConnectionError: Error {
    case eventPublisherClosedUnexpectedly
    case statePublisherClosedUnexpectedly
  }
}
extension CameraHubConnection {
  func routeCommand(_ command: CameraHubCommands) async {
    do {
      try await hub.perform(command)
    } catch {
      await controller.onError(error)
    }
  }

  func routeEvent(_ event: CameraHubEvent) async {
    await controller.notify(event)
  }

  func handleHubEventCompletion(_ completion: Subscribers.Completion<Error>) async {
    switch completion {
    case .finished:
      await controller.onError(ConnectionError.eventPublisherClosedUnexpectedly)
    case .failure(let error):
      await controller.onError(error)
    }
  }

  func updateState(_ update: CameraHubState) async {
    await controller.update(update)
  }

  func handleHubStateCompletion(_ completion: Subscribers.Completion<Error>) async {
    switch completion {
    case .finished:
      await controller.onError(ConnectionError.statePublisherClosedUnexpectedly)
    case .failure(let error):
      await controller.onError(error)
    }
  }
}
