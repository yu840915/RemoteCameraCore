import AsyncUtils
import Combine
import Testing

@testable import RemoteCameraCore

public struct FakeConnectionSuite: ConnectionArgumentProviding {
  public static let id = "fake-connection-suite"

  public init() {}
}

struct CameraHubServerTests {
  @Test
  func createAdvertiserOnStart() async throws {
    let factory = DummyAdvertiserFactory()
    var state = CameraHubState(id: "hub-1")
    state.name = "Hub 1"
    let hub = DummyCameraHub(state: state)
    let server = await CameraHubServer(localHub: hub, advertiserFactory: factory)

    try await server.perform(.startAdvertising)
    try await Task.sleep(for: .milliseconds(1))

    #expect(factory.adversisers.count == 1)
    guard let advertiser = factory.adversisers.first else {
      throw TestError.conditionFailed
    }
    #expect(advertiser.hub.id == state.id)
    #expect(advertiser.hub.name == state.name)
    #expect(advertiser.commands.count == 1)
    guard case .start = advertiser.commands.first else {
      throw TestError.conditionFailed
    }
  }

  @Test
  func doNotCreateAdvertiserTwice() async throws {
    let factory = DummyAdvertiserFactory()
    var state = CameraHubState(id: "hub-1")
    state.name = "Hub 1"
    let hub = DummyCameraHub(state: state)
    let server = await CameraHubServer(localHub: hub, advertiserFactory: factory)

    try await server.perform(.startAdvertising)
    try await Task.sleep(for: .milliseconds(1))
    try await server.perform(.startAdvertising)
    try await Task.sleep(for: .milliseconds(1))

    #expect(factory.adversisers.count == 1)
    guard let advertiser = factory.adversisers.first else {
      throw TestError.conditionFailed
    }
    #expect(advertiser.hub.id == state.id)
    #expect(advertiser.hub.name == state.name)
    #expect(advertiser.commands.count == 2)
  }

  @Test
  func updateOnAdvertiseUpdate() async throws {
    let factory = DummyAdvertiserFactory()
    var state = CameraHubState(id: "hub-1")
    state.name = "Hub 1"
    let hub = DummyCameraHub(state: state)
    let server = await CameraHubServer(localHub: hub, advertiserFactory: factory)
    let completer = await Completer<Void>()
    let stateActor = CollectionActor<CameraHubServerState>()
    await stateActor.setOnAppended { states in
      guard states.count == 2 else {
        return
      }
      Task {
        await completer.resume()
      }
    }

    try await server.perform(.startAdvertising)
    var bag = Set<AnyCancellable>()
    server
      .onState
      .eraseToAnyPublisher()
      .removeDuplicates()
      .sink { _ in
      } receiveValue: { state in
        Task {
          await stateActor.append(state)
        }
      }.store(in: &bag)
    let advertiser = factory.adversisers.first!
    var update = advertiser.state$.value
    update.requests = [
      .init(
        controller: .init(id: "controller-1", name: "Controller 1"),
        hub: .init(id: "hub-1", name: "Hub 1"),
        connectionSuite: ConnectionSuite(
          id: FakeConnectionSuite.id,
          arguments: FakeConnectionSuite(),
        ),
      )
    ]
    update.isRunning = true
    advertiser.state$.value = update
    await completer.result()

    let serverStates = await stateActor.values
    #expect(
      serverStates[(serverStates.count - 2)..<serverStates.count]
        == [
          .init(
            requests: [],
            isAdvertising: false,
            connectedControllers: []
          ),
          .init(
            requests: [
              ControlRequest(
                controller: CameraControllerDescriptor(id: "controller-1", name: "Controller 1"),
                hub: CameraHubDescriptor(id: "hub-1", name: "Hub 1"),
                connectionSuite: ConnectionSuite(
                  id: FakeConnectionSuite.id,
                  arguments: FakeConnectionSuite(),
                ),
              )
            ],
            isAdvertising: true,
            connectedControllers: []
          ),
        ]
    )
  }

  @Test
  func stopAdvertising() async throws {
    let factory = DummyAdvertiserFactory()
    var state = CameraHubState(id: "hub-1")
    state.name = "Hub 1"
    let hub = DummyCameraHub(state: state)
    let server = await CameraHubServer(localHub: hub, advertiserFactory: factory)
    let stateActor = CollectionActor<CameraHubServerState>()
    let setUp = await Completer<Void>()
    await stateActor.setOnAppended { states in
      guard let last = states.last, last.isAdvertising else {
        return
      }
      Task { await setUp.resume() }
    }
    try await server.perform(.startAdvertising)
    var bag = Set<AnyCancellable>()
    server.onState.sink { _ in
    } receiveValue: { state in
      Task { await stateActor.append(state) }
    }.store(in: &bag)
    let advertiser = factory.adversisers.first!
    var update = advertiser.state$.value
    update.requests = [
      .init(
        controller: .init(id: "controller-1", name: "Controller 1"),
        hub: .init(id: "hub-1", name: "Hub 1"),
        connectionSuite: ConnectionSuite(
          id: FakeConnectionSuite.id,
          arguments: FakeConnectionSuite(),
        ),
      )
    ]
    update.isRunning = true
    advertiser.state$.value = update
    await setUp.result()

    let completer = await Completer<Void>()
    await stateActor.setOnAppended { states in
      guard let last = states.last, !last.isAdvertising else {
        return
      }
      Task { await completer.resume() }
    }
    try await server.perform(.stopAdvertising)
    await completer.result()

    let states = await stateActor.values
    let lastState = states.last!
    #expect(lastState.isAdvertising == false)
    #expect(lastState.requests.isEmpty)
    guard case .stop = advertiser.commands.last else {
      throw TestError.conditionFailed
    }
  }

  @Test
  func stopAdvertisingBeforeStartIsNoOp() async throws {
    let factory = DummyAdvertiserFactory()
    var state = CameraHubState(id: "hub-1")
    state.name = "Hub 1"
    let hub = DummyCameraHub(state: state)
    let server = await CameraHubServer(localHub: hub, advertiserFactory: factory)

    try await server.perform(.stopAdvertising)
    try await Task.sleep(for: .milliseconds(1))

    #expect(factory.adversisers.isEmpty)
  }

  @Test
  func acceptRequest() async throws {
    let factory = DummyAdvertiserFactory()
    var state = CameraHubState(id: "hub-1")
    state.name = "Hub 1"
    let hub = DummyCameraHub(state: state)
    let server = await CameraHubServer(localHub: hub, advertiserFactory: factory)
    try await server.perform(.startAdvertising)
    try await Task.sleep(for: .milliseconds(1))
    let advertiser = factory.adversisers.first!
    let request = ControlRequest(
      controller: CameraControllerDescriptor(id: "controller-1", name: "Controller 1"),
      hub: CameraHubDescriptor(id: "hub-1", name: "Hub 1"),
      connectionSuite: ConnectionSuite(
        id: FakeConnectionSuite.id,
        arguments: FakeConnectionSuite(),
      ),
    )

    var update = advertiser.state$.value
    update.requests = [request]
    update.isRunning = true
    advertiser.state$.value = update
    try await Task.sleep(for: .milliseconds(1))
    try await server.perform(.acceptRequest(request: request))
    try await Task.sleep(for: .milliseconds(1))

    guard case .acceptRequest(let accepted) = advertiser.commands.last else {
      throw TestError.conditionFailed
    }
    #expect(accepted == request)
  }

  @Test
  func establishBindingOnClientEvent() async throws {
    let factory = DummyAdvertiserFactory()
    let hub = DummyCameraHub(
      state: CameraHubState(id: "hub-1", name: "Hub 1")
    )
    let sut = await CameraHubServer(localHub: hub, advertiserFactory: factory)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )

    let completer = await Completer<Void>()
    let stateActor = CollectionActor<CameraHubServerState>()
    await stateActor.setOnAppended { states in
      guard states.count == 2 else {
        return
      }
      Task {
        await completer.resume()
      }
    }
    var bag = Set<AnyCancellable>()
    sut.onState
      .eraseToAnyPublisher()
      .removeDuplicates().sink { _ in
      } receiveValue: { state in
        Task {
          await stateActor.append(state)
        }
      }.store(in: &bag)
    try await sut.perform(.startAdvertising)
    let advertiser = factory.adversisers.first!
    advertiser.event$.send(.cameraHubClient(controller))
    await completer.result()

    let serverStates = await stateActor.values
    let lastState: CameraHubServerState = serverStates.last!
    #expect(
      lastState.connectedControllers == [
        CameraControllerDescriptor(id: "controller-1", name: "Controller 1")
      ]
    )
  }

  @Test
  func handleUnbind() async throws {
    let factory = DummyAdvertiserFactory()
    let hub = DummyCameraHub(
      state: CameraHubState(id: "hub-1", name: "Hub 1")
    )
    let sut = await CameraHubServer(localHub: hub, advertiserFactory: factory)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )

    let setUp = await Completer<Void>()
    let stateActor = CollectionActor<CameraHubServerState>()
    await stateActor.setOnAppended { states in
      guard states.count == 2 else {
        return
      }
      Task {
        await setUp.resume()
      }
    }
    var bag = Set<AnyCancellable>()
    sut.onState
      .eraseToAnyPublisher()
      .removeDuplicates().sink { _ in
      } receiveValue: { state in
        Task {
          await stateActor.append(state)
        }
      }.store(in: &bag)
    try await sut.perform(.startAdvertising)
    let advertiser = factory.adversisers.first!
    advertiser.event$.send(.cameraHubClient(controller))
    await setUp.result()
    await stateActor.reset()

    let perform = await Completer<Void>()
    await stateActor.setOnAppended { states in
      guard states.count == 1 else {
        return
      }
      Task {
        await perform.resume()
      }
    }
    controller.status$.send(completion: .finished)
    await perform.result()

    let serverStates = await stateActor.values
    let lastState: CameraHubServerState = serverStates.last!
    #expect(
      lastState.connectedControllers == []
    )
  }

  @Test
  func beReadyIfHubIsReady() async throws {
    let factory = DummyAdvertiserFactory()
    let hub = DummyCameraHub(
      state: CameraHubState(id: "hub-1", name: "Hub 1")
    )
    let sut = await CameraHubServer(localHub: hub, advertiserFactory: factory)

    var bag = Set<AnyCancellable>()
    let completer = await TimeoutThrowingCompleter<Void>(waitFor: .seconds(1))

    sut.onStatus.sink { status in
      if status == .ready {
        Task {
          await completer.resume()
        }
      }
    }.store(in: &bag)

    hub.status$.send(.ready)

    try await completer.result()
  }

  @Test
  func cancelsServerOnHubCancellation() async throws {
    let factory = DummyAdvertiserFactory()
    let hub = DummyCameraHub(
      state: CameraHubState(id: "hub-1", name: "Hub 1")
    )
    let sut = await CameraHubServer(localHub: hub, advertiserFactory: factory)

    var bag = Set<AnyCancellable>()
    let completer = await TimeoutThrowingCompleter<Void>(waitFor: .seconds(1))
    var lastStatus: NodeStatus?

    sut.onStatus.sink { _ in
      Task {
        await completer.resume()
      }
    } receiveValue: {
      lastStatus = $0
    }.store(in: &bag)

    hub.status$.send(.cancelled(nil))

    try await completer.result()
    #expect(lastStatus == .cancelled(nil))
  }

  @Test
  func cancelsServerOnHubStatusCompletion() async throws {
    let factory = DummyAdvertiserFactory()
    let hub = DummyCameraHub(
      state: CameraHubState(id: "hub-1", name: "Hub 1")
    )
    let sut = await CameraHubServer(localHub: hub, advertiserFactory: factory)

    var bag = Set<AnyCancellable>()
    let completer = await TimeoutThrowingCompleter<Void>(waitFor: .seconds(1))
    var lastStatus: NodeStatus?

    sut.onStatus.sink { _ in
      Task {
        await completer.resume()
      }
    } receiveValue: {
      lastStatus = $0
    }.store(in: &bag)

    hub.status$.send(completion: .finished)

    try await completer.result()
    #expect(lastStatus == .cancelled(nil))
  }

  @Test
  func stopAdvertisingOnAdvertiserStatusChannelCompletion() async throws {
    let factory = DummyAdvertiserFactory()
    var state = CameraHubState(id: "hub-1")
    state.name = "Hub 1"
    let hub = DummyCameraHub(state: state)
    let sut = await CameraHubServer(localHub: hub, advertiserFactory: factory)

    let setUp = await Completer<Void>()
    let stateCompleter = await Completer<Void>()
    let stateActor = CollectionActor<CameraHubServerState>()
    var bag = Set<AnyCancellable>()
    await stateActor.setOnAppended { states in
      if states.count == 2 {
        Task {
          await setUp.resume()
        }
      } else if states.count == 3 {
        Task {
          await stateCompleter.resume()
        }
      }
    }
    sut.onState
      .eraseToAnyPublisher()
      .removeDuplicates().sink { _ in
      } receiveValue: { state in
        Task {
          await stateActor.append(state)
        }
      }.store(in: &bag)
    try await sut.perform(.startAdvertising)
    let advertiser = factory.adversisers.first!
    var update = advertiser.state$.value
    update.requests = [
      .init(
        controller: .init(id: "controller-1", name: "Controller 1"),
        hub: .init(id: "hub-1", name: "Hub 1"),
        connectionSuite: ConnectionSuite(
          id: FakeConnectionSuite.id,
          arguments: FakeConnectionSuite(),
        ),
      )
    ]
    update.isRunning = true
    advertiser.state$.value = update
    await setUp.result()

    advertiser.status$.send(.cancelled(MockError()))
    await stateCompleter.result()

    let serverStates = await stateActor.values
    let lastState: CameraHubServerState = serverStates.last!
    #expect(
      lastState
        == .init(
          requests: [],
          isAdvertising: false,
          connectedControllers: []
        )
    )
  }
}
