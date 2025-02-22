import Combine

actor CameraHubServerActor {
  final let localHub: any CameraHubServicePort
  final let advertiserFactory: any CameraHubAdvertiserFactoryPort
  private var advertiser: (any CameraHubAdvertisingServicePort)?
  private var adversiserBag: Set<AnyCancellable> = []
  private var bag = Set<AnyCancellable>()
  var stateSequence: AsyncThrowingStream<CameraHubServerState, any Error>?
  var eventSequence: AsyncThrowingStream<CameraHubServerEvent, any Error>?
  let state$ = CurrentValueSubject<CameraHubServerState, any Error>(.init())
  let event$ = PassthroughSubject<CameraHubServerEvent, any Error>()
  private var bindings: [CameraHubServiceClientBinding] = [] {
    didSet {
      var update = state$.value
      update.connectedControllers = bindings.map { $0.client.controllerDescriptor }
      state$.value = update
    }
  }

  init(
    localHub: some CameraHubServicePort,
    advertiserFactory: some CameraHubAdvertiserFactoryPort
  ) async {
    self.localHub = localHub
    self.advertiserFactory = advertiserFactory
    setUpStream()
  }

  func perform(_ command: CameraHubServerCommand) async throws {
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
  fileprivate func setUpStream() {
    stateSequence = AsyncThrowingStream { [weak self] continuation in
      Task { [weak self] in await self?.listenToState(with: continuation) }
    }
    eventSequence = AsyncThrowingStream { [weak self] continuation in
      Task { [weak self] in await self?.listenToEvent(with: continuation) }
    }
  }

  fileprivate func listenToState(
    with continuation: AsyncThrowingStream<CameraHubServerState, any Error>.Continuation
  ) {
    state$.sink { completion in
      switch completion {
      case .finished:
        continuation.finish()
      case let .failure(error):
        continuation.finish(throwing: error)
      }
    } receiveValue: { CameraHubServerState in
      continuation.yield(CameraHubServerState)
    }.store(in: &bag)
  }

  fileprivate func listenToEvent(
    with continuation: AsyncThrowingStream<CameraHubServerEvent, any Error>.Continuation
  ) {
    event$.sink { completion in
      switch completion {
      case .finished:
        continuation.finish()
      case let .failure(error):
        continuation.finish(throwing: error)
      }
    } receiveValue: { event in
      continuation.yield(event)
    }.store(in: &bag)
  }

  fileprivate func prepareAdvertiser() -> any CameraHubAdvertisingServicePort {
    if let advertiser = advertiser {
      return advertiser
    }
    let advertiser = advertiserFactory.createHubAdvertiser(
      with: .init(
        id: localHub.id,
        name: localHub.state.name
      )
    )
    var bag = Set<AnyCancellable>()
    advertiser.onState.sink { [weak self] _ in

    } receiveValue: { [weak self] state in
      Task { [weak self] in
        await self?.onAdvertiserState(state)
      }
    }.store(in: &bag)
    advertiser.onEvent.sink { [weak self] _ in

    } receiveValue: { [weak self] event in
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
    state$.value = update
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

  fileprivate func waitBinding(_ binding: CameraHubServiceClientBinding) async {
    do {
      try await binding.waitUnbound()
    } catch {
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
