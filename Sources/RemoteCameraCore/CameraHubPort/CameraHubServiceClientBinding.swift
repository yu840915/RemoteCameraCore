import AsyncUtils
import Combine

public actor CameraHubServiceClientBinding {
  public typealias Service = CameraHubServicePort
  public typealias Client = CameraHubClientPort
  let service: any Service
  let client: any Client
  let completor: ThrowingCompleter<Void>
  private var isBound = true
  private var bag = Set<AnyCancellable>()

  public init(client: some Client, service: some Service) async {
    self.client = client
    self.service = service
    completor = await ThrowingCompleter()
    var bag = Set<AnyCancellable>()
    client.onCommand.sink { [weak self] completion in
      Task { [weak self] in
        await self?.handleCommandChannelCompletion(completion)
      }
    } receiveValue: { [weak self] command in
      Task { [weak self] in
        await self?.routeCommand(command)
      }
    }.store(in: &bag)
    service.onState.sink { [weak self] completion in
      Task { [weak self] in
        await self?.handleStateChannelCompletion(completion)
      }
    } receiveValue: { [weak self] state in
      Task { [weak self] in
        await self?.routeState(state)
      }
    }.store(in: &bag)
    service.onEvent.sink { [weak self] completion in
      Task { [weak self] in
        await self?.handleEventChannelCompletion(completion)
      }
    } receiveValue: { [weak self] event in
      Task { [weak self] in
        await self?.routeEvent(event)
      }
    }.store(in: &bag)
    updateBag(bag)
  }

  public func waitUnbound() async throws {
    try await completor.result()
  }

  public func unbind(_ error: Error?, localTriggered: Bool) async {
    guard isBound else { return }
    isBound = false
    bag = []
    await client.unbind(localTriggered ? error : nil)
    if let error = error {
      await completor.resume(throwing: error)
    } else {
      await completor.resume()
    }
  }
}

extension CameraHubServiceClientBinding {
  fileprivate func updateBag(_ bag: Set<AnyCancellable>) {
    self.bag = bag
  }

  fileprivate func routeCommand(_ command: CameraHubCommand) async {
    do {
      try await service.perform(command)
    } catch {
      await client.onError(error)
    }
  }

  fileprivate func routeState(_ state: CameraHubState) async {
    await client.update(state)
  }

  fileprivate func routeEvent(_ event: CameraHubEvent) async {
    await client.notify(event)
  }

  fileprivate func handleStateChannelCompletion(
    _ completion: Subscribers.Completion<Error>
  ) async {
    let error =
      switch completion {
      case .finished: BindingError.statePublisherClosed
      case .failure(let error): error
      }
    await unbind(error, localTriggered: true)
  }

  fileprivate func handleEventChannelCompletion(
    _ completion: Subscribers.Completion<Error>
  ) async {
    let error =
      switch completion {
      case .finished: BindingError.eventPublisherClosed
      case .failure(let error): error
      }
    await unbind(error, localTriggered: true)
  }

  fileprivate func handleCommandChannelCompletion(
    _ completion: Subscribers.Completion<Error>
  ) async {
    switch completion {
    case .finished:
      await unbind(BindingError.commandPublisherClosed, localTriggered: false)
    case .failure(let error):
      await unbind(error, localTriggered: false)
    }
  }
}
