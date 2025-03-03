import AsyncUtils
import Combine

public actor CaptureServiceClientBinding {
  public typealias Service = CaptureServicePort
  public typealias Client = CaptureClientPort
  public let service: any Service
  public let client: any Client

  let completor: ThrowingCompleter<Void>
  private var isBound = true
  private var lastState = CaptureServiceState()
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
    await routeState(service.state)
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

extension CaptureServiceClientBinding {
  fileprivate func updateBag(_ bag: Set<AnyCancellable>) {
    self.bag = bag
  }

  fileprivate func routeState(_ state: CaptureServiceState) async {
    await withTaskGroup(of: Void.self) { [weak self, lastState] group in
      group.addTask { [weak self] in
        if state.configuration != lastState.configuration {
          await self?.client.update(.configuration(state.configuration))
        }
      }
      group.addTask { [weak self] in
        if state.availableConfigurationCommands != lastState.availableConfigurationCommands {
          await self?.client.update(
            .availableConfigurationCommands(state.availableConfigurationCommands)
          )
        }
      }
      group.addTask { [weak self] in
        if let camera = state.camera, camera != lastState.camera {
          await self?.client.update(.cameraDescriptor(camera))
        }
      }
      group.addTask { [weak self] in
        if state.capabilities != lastState.capabilities {
          await self?.client.update(.capabilities(state.capabilities))
        }
      }
    }
    lastState = state
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

  fileprivate func routeCommand(_ command: CaptureServiceCommand) async {
    do {
      try await service.perform(command)
    } catch {
      await client.report(error)
    }
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

  fileprivate func routeEvent(_ event: CaptureServiceEvent) async {
    await client.notify(event)
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
}
