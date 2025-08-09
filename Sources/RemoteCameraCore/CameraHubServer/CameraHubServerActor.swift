import AsyncUtils
import Combine

actor CameraHubServerActor {
  final let localHub: any CameraHubServicePort
  final let advertiserFactory: any CameraHubAdvertiserFactoryPort
  private var advertiser: (any CameraHubAdvertisingServicePort)?
  private var adversiserBag: Set<AnyCancellable> = []
  var statusStream: AsyncStream<NodeStatus> {
    statusStreamWriter.stream
  }
  var stateStream: AsyncStream<CameraHubServerState> {
    stateStreamPipe.stream
  }
  var eventStream: AsyncStream<CameraHubServerEvent> {
    eventStreamWriter.stream
  }
  var errorStream: AsyncStream<Error> {
    errorStreamWriter.stream
  }
  private let statusStreamWriter = AsyncStreamWriter<NodeStatus>()
  private let eventStreamWriter = AsyncStreamWriter<CameraHubServerEvent>()
  private let errorStreamWriter = AsyncStreamWriter<Error>()
  private let stateStreamPipe: SubjectToAsyncStreamPipe<CameraHubServerState>
  private let state$ = CurrentValueSubject<CameraHubServerState, Never>(.init())
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
    stateStreamPipe = SubjectToAsyncStreamPipe(state$)
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

  fileprivate func handleHubStatus(_ status: NodeStatus) async {
    statusStreamWriter.send(status)
    if case .cancelled = status {
      statusStreamWriter.finish()
    }
  }

  fileprivate func onHubStatusCompletion() {
    statusStreamWriter.send(.cancelled(nil))
    statusStreamWriter.finish()
  }

  fileprivate func onAdvertiserStatus(_ status: NodeStatus) {
    if case .cancelled = status {
      onAdvertiserStatusCompletion()
    }
  }

  fileprivate func onAdvertiserStatusCompletion() {
    eventStreamWriter.send(.advertiserStopped(nil))
    removeAdvertiser()
  }

  fileprivate func waitBinding(_ binding: CameraHubServiceClientBinding) async {
    do {
      try await binding.waitUnbound()
    } catch {
      errorStreamWriter.send(error)
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
