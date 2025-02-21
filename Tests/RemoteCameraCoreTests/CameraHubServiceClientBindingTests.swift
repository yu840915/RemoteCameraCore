import Testing

@testable import RemoteCameraCore

struct CameraHubServiceClientBindingTests {
  let state: CameraHubState = {
    var state = CameraHubState(id: "hub-1")
    state.name = "Hub 1"
    return state
  }()
  @Test
  func routeCommand() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)

    controller.command$.send(
      .requestCapture(
        args: .init(
          camera: CameraDescriptor(id: "cam01", name: "front came", position: .builtInFront)
        )
      )
    )
    try await Task.sleep(for: .milliseconds(1))

    #expect(hub.commands.count == 1)
    guard case let .requestCapture(args) = hub.commands.first else {
      throw TestError.conditionFailed
    }
    #expect(
      args
        == CaptureServiceArguments(
          camera: CameraDescriptor(
            id: "cam01",
            name: "front came",
            position: .builtInFront
          )
        )
    )
    print(sut)
  }

  @Test
  func routeState() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)
    try await Task.sleep(for: .milliseconds(1))

    hub.state$.value.cameras = [
      CameraDescriptor(id: "cam01", name: "front camera", position: .builtInFront),
      CameraDescriptor(id: "cam02", name: "back camera", position: .builtInBack),
    ]
    try await Task.sleep(for: .milliseconds(1))

    #expect(controller.updates.count == 2)
    guard let update = controller.updates.last else {
      throw TestError.conditionFailed
    }
    #expect(update.id == "hub-1")
    #expect(update.name == "Hub 1")
    #expect(
      update.cameras == [
        CameraDescriptor(id: "cam01", name: "front camera", position: .builtInFront),
        CameraDescriptor(id: "cam02", name: "back camera", position: .builtInBack),
      ]
    )
    print(sut)
  }

  @Test
  func reportErrorOnStateChannelClose() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)

    await confirmation { confirmation in
      Task.detached {
        hub.state$.send(completion: .finished)
      }

      do {
        try await sut.waitUnbound()
      } catch {
        confirmation()
      }
    }

    #expect(controller.errors.count == 1)
    print(sut)
  }

  @Test
  func propagateStateChannelError() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)
    await confirmation { confirmation in
      Task {
        hub.state$.send(completion: .failure(MockError()))
      }

      do {
        try await sut.waitUnbound()
      } catch {
        confirmation()
      }
    }

    #expect(controller.errors.count == 1)
    print(sut)
  }

  @Test
  func handleEvent() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let capture = DummyCapture()
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)

    hub.event$.send(.capture(capture: capture))
    try await Task.sleep(for: .milliseconds(1))

    #expect(controller.events.count == 1)
    guard
      case let .capture(arg) = controller.events.first,
      let argCapture = arg as? DummyCapture
    else {
      throw TestError.conditionFailed
    }
    #expect(capture === argCapture)
    print(sut)
  }

  @Test
  func reportErrorOnEventChannelClose() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)

    await confirmation { confirmation in
      Task.detached {
        hub.event$.send(completion: .finished)
      }

      do {
        try await sut.waitUnbound()
      } catch {
        confirmation()
      }
    }

    #expect(controller.errors.count == 1)
    print(sut)
  }

  @Test
  func propagateEventChannelError() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)
    await confirmation { confirmation in
      Task.detached {
        hub.event$.send(completion: .failure(MockError()))
      }

      do {
        try await sut.waitUnbound()
      } catch {
        confirmation()
      }
    }

    #expect(controller.errors.count == 1)
    print(sut)
  }

  @Test
  func terminateOnCommandChannelClose() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)

    await confirmation { confirmation in
      Task.detached {
        controller.command$.send(completion: .finished)
      }

      do {
        try await sut.waitUnbound()
      } catch {
        confirmation()
      }
    }
  }

  @Test
  func propagateCommandChannelError() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)
    await confirmation { confirmation in
      Task {
        controller.command$.send(completion: .failure(MockError()))
      }

      do {
        try await sut.waitUnbound()
      } catch {
        confirmation()
      }
    }
  }

  @Test
  func skipFollowingChannelError() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)
    await confirmation { confirmation in
      Task {
        hub.event$.send(completion: .failure(MockError()))
        hub.state$.send(completion: .failure(MockError()))
      }

      do {
        try await sut.waitUnbound()
      } catch {
        confirmation()
      }
    }
  }
}
