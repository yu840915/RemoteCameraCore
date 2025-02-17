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
      throw TestError.preconditionFailed
    }
    #expect(advertiser.hub.id == state.id)
    #expect(advertiser.hub.name == state.name)
    #expect(advertiser.commands.count == 1)
    guard case .start = advertiser.commands.first else {
      throw TestError.preconditionFailed
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
      throw TestError.preconditionFailed
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

    var serverState: CameraHubServerState?
    try await confirmation(nil, expectedCount: 2) { confirmation in
      var bag = Set<AnyCancellable>()
      server.onState.sink { _ in
      } receiveValue: { state in
        serverState = state
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
      serverState
        == CameraHubServerState(
          requests: [
            ControlRequest(
              controller: CameraControllerDescriptor(id: "controller-1", name: "Controller 1"),
              hub: CameraHubDescriptor(id: "hub-1", name: "Hub 1")
            )
          ],
          isAdvertising: true,
          connectedControllers: []
        )
    )
  }
}
