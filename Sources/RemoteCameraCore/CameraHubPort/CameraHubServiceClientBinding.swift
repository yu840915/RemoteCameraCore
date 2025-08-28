import AsyncUtils
import Combine

public actor CameraHubServiceClientBinding {
  public typealias Service = CameraHubServicePort
  public typealias Client = CameraHubClientPort
  typealias StatusChannelCompletion = Subscribers.Completion<Never>
  private let status$: CurrentValueSubject<NodeStatus, Never>
  var onStatus: NonSendable<any Publisher<NodeStatus, Never>> {
    NonSendable(status$)
  }
  let service: any Service
  let client: any Client
  let completor: ThrowingCompleter<Void>
  private var isBound = true
  nonisolated(unsafe) private var clientBag = Set<AnyCancellable>()
  nonisolated(unsafe) private var serviceBag = Set<AnyCancellable>()
  nonisolated(unsafe) private var statusBag = Set<AnyCancellable>()

  public init(client: some Client, service: some Service) async {
    self.client = client
    self.service = service
    status$ = .init(.preparing)
    completor = await ThrowingCompleter()
    var bag = Set<AnyCancellable>()
    service.onStatus.sink { [weak self] _ in
      Task { [weak self] in
        await self?.handleServiceChannelCompletion()
      }
    } receiveValue: { [weak self] status in
      Task { [weak self] in
        await self?.handleServiceStatus(status)
      }
    }.store(in: &bag)
    client.onStatus.sink { [weak self] _ in
      Task { [weak self] in
        await self?.handleClientChannelCompletion()
      }
    } receiveValue: { [weak self] status in
      Task { [weak self] in
        await self?.handleClientStatus(status)
      }
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
    statusBag = bag
  }

  public func waitUnbound() async throws {
    try await completor.result()
  }

  public func unbind(_ error: Error?, localTriggered: Bool) async {
    guard isBound else { return }
    isBound = false
    statusBag = []
    await client.unbind(localTriggered ? error : nil)
    if let error = error {
      await completor.resume(throwing: error)
    } else {
      await completor.resume()
    }
  }
}

extension CameraHubServiceClientBinding {
  fileprivate func routeCommand(_ command: CameraHubCommand) async {
    do {
      try await service.perform(command)
    } catch {
      await client.report(error)
    }
  }

  fileprivate func routeState(_ state: CameraHubState) async {
    await client.update(state)
  }

  fileprivate func routeEvent(_ event: CameraHubEvent) async {
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

  fileprivate func handleServiceStatus(_ status: NodeStatus) async {
    switch status {
    case .ready: prepareClientChannels()
    default: clientBag = []
    }
  }

  fileprivate func prepareClientChannels() {
    client.onCommand.sink { [weak self] command in
      Task { [weak self] in
        await self?.routeCommand(command)
      }
    }.store(in: &clientBag)
  }

  fileprivate func handleClientStatus(_ status: NodeStatus) async {
    switch status {
    case .ready:
      prepareServiceChannels()
      await routeState(service.state)
    default: serviceBag = []
    }
  }

  fileprivate func prepareServiceChannels() {
    service.onState.sink { [weak self] state in
      Task { [weak self] in
        await self?.routeState(state)
      }
    }.store(in: &serviceBag)
    service.onEvent.sink { [weak self] event in
      Task { [weak self] in
        await self?.routeEvent(event)
      }
    }.store(in: &serviceBag)
  }

  fileprivate func handleServiceChannelCompletion() async {
    await unbind(BindingError.serviceClosed, localTriggered: true)
  }

  fileprivate func handleClientChannelCompletion() async {
    await unbind(BindingError.clientClosed, localTriggered: true)
  }
}
