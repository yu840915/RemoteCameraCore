import AsyncUtils
import Combine

public actor CaptureServiceClientBinding {
  public typealias Service = CaptureServicePort
  public typealias Client = CaptureClientPort
  public let service: any Service
  public let client: any Client
  public var onStatus: NonSendable<any Publisher<NodeStatus, Never>> {
    NonSendable(status$)
  }
  let completor: ThrowingCompleter<Void>
  private var isBound = true
  private let status$ = CurrentValueSubject<NodeStatus, Never>(.preparing)
  private var lastState = CaptureServiceState()
  private var bag = Set<AnyCancellable>()

  public init(client: some Client, service: some Service) async {
    self.client = client
    self.service = service
    completor = await ThrowingCompleter()
    var bag = Set<AnyCancellable>()
    client.onStatus.sink { [weak self] _ in
      Task { [weak self] in
        await self?.handleClientChannelCompletion()
      }
    } receiveValue: { _ in
    }.store(in: &bag)
    service.onStatus.sink { [weak self] completion in
      Task { [weak self] in
        await self?.handleServiceChannelCompletion()
      }
    } receiveValue: { _ in
    }.store(in: &bag)
    Publishers.CombineLatest(
      service.onStatus.eraseToAnyPublisher(),
      client.onStatus.eraseToAnyPublisher(),
    ).map { NodeStatusMerger().merge([$0.0, $0.1]) }
      .removeDuplicates()
      .sink { [weak self] status in
        Task { [weak self] in
          await self?.handleStatus(status)
        }
      }.store(in: &bag)
    client.onCommand.sink { [weak self] command in
      Task { [weak self] in
        await self?.routeCommand(command)
      }
    }.store(in: &bag)
    service.onState.sink { [weak self] state in
      Task { [weak self] in
        await self?.routeState(state)
      }
    }.store(in: &bag)
    service.onEvent.sink { [weak self] event in
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

  fileprivate func handleServiceChannelCompletion() async {
    await unbind(BindingError.serviceClosed, localTriggered: true)
  }

  fileprivate func handleClientChannelCompletion() async {
    await unbind(BindingError.clientClosed, localTriggered: true)
  }

  fileprivate func routeState(_ state: CaptureServiceState) async {
    var messages = [CaptureServiceStateUpdateMessage]()
    if state.capabilities != lastState.capabilities {
      messages.append(.capabilities(state.capabilities))
    }
    if state.availableConfigurationCommands != lastState.availableConfigurationCommands {
      messages.append(
        .availableConfigurationCommands(state.availableConfigurationCommands)
      )
    }
    if state.configuration != lastState.configuration {
      messages.append(.configuration(state.configuration))
    }
    if let camera = state.camera, camera != lastState.camera {
      messages.append(.cameraDescriptor(camera))
    }
    lastState = state
    await withTaskGroup(of: Void.self) { [weak self] group in
      for message in messages {
        group.addTask { [weak self] in
          await self?.client.update(message)
        }
      }
    }
  }

  fileprivate func routeCommand(_ command: CaptureServiceCommand) async {
    do {
      try await service.perform(command)
    } catch {
      await client.report(error)
    }
  }

  fileprivate func routeEvent(_ event: CaptureServiceEvent) async {
    await client.notify(event)
  }

  fileprivate func handleStatus(_ status: NodeStatus) async {
    if status$.value != status {
      status$.send(status)
    }
    if case .cancelled(let error) = status {
      await unbind(error, localTriggered: true)
    }
  }
}
