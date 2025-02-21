import Combine
import Testing

@testable import RemoteCameraCore

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
    try await server.perform(.startAdvertising)
    try await Task.sleep(for: .milliseconds(1))
    let advertiser = factory.adversisers.first!

    var serverStates: [CameraHubServerState] = []
    try await confirmation(nil, expectedCount: 2) { confirmation in
      var bag = Set<AnyCancellable>()
      server.onState.sink { _ in
      } receiveValue: { state in
        serverStates.append(state)
        confirmation()
      }.store(in: &bag)
      var update = advertiser.state$.value
      update.requests = [
        .init(
          controller: .init(id: "controller-1", name: "Controller 1"),
          hub: .init(id: "hub-1", name: "Hub 1")
        )
      ]
      update.isRunning = true
      advertiser.state$.value = update
      try await Task.sleep(for: .milliseconds(1))
    }

    #expect(
      serverStates
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
                hub: CameraHubDescriptor(id: "hub-1", name: "Hub 1")
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

    try await server.perform(.startAdvertising)
    try await Task.sleep(for: .milliseconds(1))
    let advertiser = factory.adversisers.first!

    var serverStates: [CameraHubServerState] = []
    try await confirmation(nil, expectedCount: 3) { confirmation in
      var bag = Set<AnyCancellable>()
      server.onState.sink { _ in
      } receiveValue: { state in
        serverStates.append(state)
        confirmation()
      }.store(in: &bag)
      var update = advertiser.state$.value
      update.requests = [
        .init(
          controller: .init(id: "controller-1", name: "Controller 1"),
          hub: .init(id: "hub-1", name: "Hub 1")
        )
      ]
      update.isRunning = true
      advertiser.state$.value = update
      try await Task.sleep(for: .milliseconds(1))
      try await server.perform(.stopAdvertising)
      try await Task.sleep(for: .milliseconds(1))
    }

    #expect(serverStates.count == 3)
    let lastState = serverStates.last!
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
      hub: CameraHubDescriptor(id: "hub-1", name: "Hub 1")
    )

    var update = advertiser.state$.value
    update.requests = [request]
    update.isRunning = true
    advertiser.state$.value = update
    try await Task.sleep(for: .milliseconds(1))
    try await server.perform(.acceptRequest(request: request))
    try await Task.sleep(for: .milliseconds(1))

    guard case let .acceptRequest(accepted) = advertiser.commands.last else {
      throw TestError.conditionFailed
    }
    #expect(accepted == request)
  }

  @Test
  func establishConnectionOnClientEvent() async throws {
    let factory = DummyAdvertiserFactory()
    var state = CameraHubState(id: "hub-1")
    state.name = "Hub 1"
    let hub = DummyCameraHub(state: state)
    let server = await CameraHubServer(localHub: hub, advertiserFactory: factory)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    try await server.perform(.startAdvertising)
    try await Task.sleep(for: .milliseconds(1))
    let advertiser = factory.adversisers.first!

    var serverStates: [CameraHubServerState] = []
    try await confirmation(nil, expectedCount: 2) { confirmation in
      var bag = Set<AnyCancellable>()
      server.onState.sink { _ in
      } receiveValue: { state in
        serverStates.append(state)
        confirmation()
      }.store(in: &bag)
      advertiser.event$.send(.cameraHubClient(controller))
      try await Task.sleep(for: .milliseconds(1))
    }

    #expect(serverStates.count == 2)
    let lastState: CameraHubServerState = serverStates.last!
    #expect(
      lastState.connectedControllers == [
        CameraControllerDescriptor(id: "controller-1", name: "Controller 1")
      ]
    )
  }
}
