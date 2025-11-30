import AsyncUtils
@preconcurrency import Combine

actor CameraHubServerActor {
  final let localHub: any CameraHubServicePort
  final let advertiserFactory: any CameraHubAdvertiserFactoryPort
  private var advertiser: (any CameraHubAdvertisingServicePort)?
  private var adversiserBag: Set<AnyCancellable> = []
  private let state$: CurrentValueSubject<CameraHubServerState, Never>
  private let status$: CurrentValueSubject<NodeStatus, Never>
  private let event$: PassthroughSubject<CameraHubServerEvent, Never>
  private let error$: PassthroughSubject<Error, Never>
  let onState: AnyPublisher<CameraHubServerState, Never>
  let onStatus: AnyPublisher<NodeStatus, Never>
  let onEvent: AnyPublisher<CameraHubServerEvent, Never>
  let onError: AnyPublisher<Error, Never>
  private var bindings: [CameraHubServiceClientBinding] = [] {
    didSet {
      var update = state$.value
      update.connectedControllers = bindings.map { $0.client.controllerDescriptor }
      state$.value = update
    }
  }
  private var advertiserBag = Set<AnyCancellable>()
  private var hubBag: Set<AnyCancellable> = []

  init(
    localHub: some CameraHubServicePort,
    advertiserFactory: some CameraHubAdvertiserFactoryPort
  ) async {
    self.localHub = localHub
    self.advertiserFactory = advertiserFactory
    state$ = .init(CameraHubServerState())
    status$ = .init(.preparing)
    event$ = .init()
    error$ = .init()
    onState = state$.eraseToAnyPublisher()
    onStatus = status$.eraseToAnyPublisher()
    onEvent = event$.eraseToAnyPublisher()
    onError = error$.eraseToAnyPublisher()
    localHub.onStatus.sink { [weak self] _ in
      Task { [weak self] in
        await self?.onHubStatusCompletion()
      }
    } receiveValue: { [weak self] status in
      Task { [weak self] in
        await self?.handleHubStatus(status)
      }
    }.store(in: &hubBag)
  }

  func perform(_ command: CameraHubServerCommand) async throws {
    //TODO: check hub status before acting
    switch command {
    case .startAdvertising:
      try await startAdvertising()
    case .stopAdvertising:
      try await stopAdvertising()
    case let .acceptRequest(request):
      try await acceptRequest(request)
    default:
      break
    }
  }
}

extension CameraHubServerActor {
  fileprivate func prepareAdvertiser() async -> any CameraHubAdvertisingServicePort {
    if let advertiser = advertiser {
      return advertiser
    }
    let advertiser = await advertiserFactory.createHubAdvertiser(
      with: .init(
        id: localHub.id,
        name: localHub.state.name
      )
    )
    var bag = Set<AnyCancellable>()
    advertiser.onStatus.sink { [weak self] _ in
      Task { [weak self] in
        await self?.onAdvertiserStatusCompletion()
      }
    } receiveValue: { [weak self] status in
      Task { [weak self] in
        await self?.onAdvertiserStatus(status)
      }
    }.store(in: &bag)
    advertiser.onState.sink { [weak self] state in
      Task { [weak self] in
        await self?.onAdvertiserState(state)
      }
    }.store(in: &bag)
    advertiser.onEvent.sink { [weak self] event in
      Task { [weak self] in
        await self?.onAdvertiserEvent(event)
      }
    }.store(in: &bag)
    self.advertiser = advertiser
    adversiserBag = bag
    return advertiser
  }

  fileprivate func onAdvertiserState(_ state: CameraHubAdvertisingServiceState) async {
    var update = state$.value
    update.isAdvertising = state.isRunning
    update.requests = state.requests
    state$.send(update)
  }

  fileprivate func onAdvertiserEvent(_ event: CameraHubAdvertisingServiceEvent) async {
    switch event {
    case let .cameraHubClient(client):
      let binding = await CameraHubServiceClientBinding(client: client, service: localHub)
      bindings.append(binding)
      Task { [weak self] in
        await self?.waitBinding(binding)
      }
    }
  }

  fileprivate func handleHubStatus(_ status: NodeStatus) async {
    status$.send(status)
    if case .cancelled = status {
      status$.send(completion: .finished)
    }
  }

  fileprivate func onHubStatusCompletion() {
    status$.send(.cancelled(nil))
    status$.send(completion: .finished)
  }

  fileprivate func onAdvertiserStatus(_ status: NodeStatus) {
    if case .cancelled = status {
      onAdvertiserStatusCompletion()
    }
  }

  fileprivate func onAdvertiserStatusCompletion() {
    event$.send(.advertiserStopped(nil))
    removeAdvertiser()
  }

  fileprivate func waitBinding(_ binding: CameraHubServiceClientBinding) async {
    do {
      try await binding.waitUnbound()
    } catch {
      error$.send(error)
    }
    remove(binding)
  }

  fileprivate func remove(_ binding: CameraHubServiceClientBinding) {
    bindings.removeAll { $0 === binding }
  }

  fileprivate func startAdvertising() async throws {
    try await prepareAdvertiser().perform(.start)
  }

  fileprivate func stopAdvertising() async throws {
    guard let advertiser = advertiser else {
      return
    }
    try await advertiser.perform(.stop)
    removeAdvertiser()
  }

  fileprivate func acceptRequest(_ request: ControlRequest) async throws {
    guard let advertiser = advertiser else {
      return
    }
    try await advertiser.perform(.acceptRequest(request: request))
  }

  fileprivate func removeAdvertiser() {
    adversiserBag = []
    advertiser = nil
    var update = state$.value
    update.isAdvertising = false
    update.requests = []
    state$.value = update
  }
}
