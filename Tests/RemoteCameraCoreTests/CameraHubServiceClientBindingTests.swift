import AsyncUtils
@preconcurrency import Combine
import Testing

@testable import RemoteCameraCore

struct CameraHubServiceClientBindingTests {
  let state: CameraHubState = {
    var state = CameraHubState(id: "hub-1")
    state.name = "Hub 1"
    return state
  }()

  @Test
  func routeCommandWhenServiceIsReady() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)

    hub.status$.send(.ready)
    try await Task.sleep(for: .milliseconds(1))
    controller.command$.send(
      .requestCapture(
        args: .init(
          camera: CameraDescriptor(id: "cam01", name: "front came", position: .builtInFront)
        )
      )
    )
    try await Task.sleep(for: .milliseconds(10))

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
  func dropCommandWhenServiceIsNotReady() async throws {
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
    try await Task.sleep(for: .milliseconds(10))

    #expect(hub.commands.count == 0)
    print(sut)
  }

  @Test
  func routeStateWhenClientIsReady() async throws {
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

    controller.status$.send(.ready)
    try await Task.sleep(for: .milliseconds(1))

    let updates = await controller.actor.updates
    #expect(updates.count > 0)
    guard let update = updates.last else {
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
  func dropStateWhenClientIsNotReady() async throws {
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

    let updates = await controller.actor.updates
    #expect(updates.count == 0)

    print(sut)
  }

  @Test
  func reportErrorOnHubStatusChannelClose() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)

    await confirmation { confirmation in
      Task.detached {
        hub.status$.send(completion: .finished)
      }

      do {
        try await sut.waitUnbound()
      } catch {
        confirmation()
      }
    }

    guard case .error = await controller.actor.unbindInvocation else {
      throw TestError.conditionFailed
    }
    print(sut)
  }

  @Test
  func reportErrorOnControllerStatusChannelClose() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)

    await confirmation { confirmation in
      Task.detached {
        controller.status$.send(completion: .finished)
      }

      do {
        try await sut.waitUnbound()
      } catch {
        confirmation()
      }
    }

    guard case .error = await controller.actor.unbindInvocation else {
      throw TestError.conditionFailed
    }
    print(sut)
  }

  @Test
  func routeEventIfClientIsReady() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let capture = DummyCapture()
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)

    controller.status$.send(.ready)
    try await Task.sleep(for: .milliseconds(1))
    hub.event$.send(.capture(capture: capture))
    try await Task.sleep(for: .milliseconds(1))

    let events = await controller.actor.events
    #expect(events.count == 1)
    guard
      case let .capture(arg) = events.first,
      let argCapture = arg as? DummyCapture
    else {
      throw TestError.conditionFailed
    }
    #expect(capture === argCapture)
    print(sut)
  }

  @Test
  func dropEventIfClientIsNotReady() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let capture = DummyCapture()
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)

    hub.event$.send(.capture(capture: capture))
    try await Task.sleep(for: .milliseconds(1))

    let events = await controller.actor.events
    #expect(events.count == 0)
    print(sut)
  }

  @Test
  func reportReadyOnBothReady() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)

    let completer = await TimeoutThrowingCompleter<Void>(waitFor: .seconds(1))
    var values = [NodeStatus]()
    var bag = Set<AnyCancellable>()
    await sut.onStatus.sink { status in
      values.append(status)
      if case .ready = status {
        Task {
          await completer.resume()
        }
      }
    }.store(in: &bag)
    hub.status$.send(.ready)
    controller.status$.send(.ready)

    try await completer.result()

    #expect(values == [.preparing, .ready])
  }

  @Test
  func unbindOnCancelStatus() async throws {
    let hub = DummyCameraHub(state: state)
    let controller = DummyHubController(
      controllerDescriptor: .init(id: "controller-1", name: "Controller 1")
    )
    let sut = await CameraHubServiceClientBinding(client: controller, service: hub)

    var outError: Error?
    await confirmation { confirmation in
      Task.detached {
        hub.status$.send(.ready)
        controller.status$.send(.cancelled(MockError()))
      }

      do {
        try await sut.waitUnbound()
      } catch {
        outError = error
        confirmation()
      }
    }

    #expect(outError is MockError)
  }
}
