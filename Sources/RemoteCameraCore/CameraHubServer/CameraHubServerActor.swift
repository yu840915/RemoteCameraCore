import AsyncUtils
import Combine

actor CameraHubServerActor {
  final let localHub: any CameraHubServicePort
  final let advertiserFactory: any CameraHubAdvertiserFactoryPort
  private var advertiser: (any CameraHubAdvertisingServicePort)?
  private var adversiserBag: Set<AnyCancellable> = []
  var stateStream: AsyncThrowingStream<CameraHubServerState, any Error> {
    stateStreamPipe.stream
  }
  var eventStream: AsyncThrowingStream<CameraHubServerEvent, any Error> {
    eventStreamWriter.stream
  }
  var errorStream: AsyncStream<Error> {
    errorStreamWriter.stream
  }
  private let eventStreamWriter = AsyncThrowingStreamWriter<CameraHubServerEvent>()
  private let errorStreamWriter = AsyncStreamWriter<Error>()
  private let stateStreamPipe: SubjectToAsyncThrowingStreamPipe<CameraHubServerState, any Error>
  private let state$ = CurrentValueSubject<CameraHubServerState, any Error>(.init())
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
    stateStreamPipe = SubjectToAsyncThrowingStreamPipe(state$)
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
    advertiser.onState.sink { [weak self] completion in
      Task { [weak self] in
        await self?.onAdvertiserChannelCompletion(completion)
      }
    } receiveValue: { [weak self] state in
      Task { [weak self] in
        await self?.onAdvertiserState(state)
      }
    }.store(in: &bag)
    advertiser.onEvent.sink { [weak self] completion in
      Task { [weak self] in
        await self?.onAdvertiserChannelCompletion(completion)
      }
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

  fileprivate func onAdvertiserChannelCompletion(_ completion: Subscribers.Completion<any Error>) {
    switch completion {
    case let .failure(error):
      eventStreamWriter.send(.advertiserStopped(error))
    case .finished:
      eventStreamWriter.send(.advertiserStopped(nil))
    }
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
