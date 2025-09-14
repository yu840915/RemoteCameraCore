import AsyncUtils
import Combine
import RemoteCameraCore
import Testing

struct CaptureServiceClientBindingTests {
  @Test
  func routeCommandIfCaptureIsReady() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

    capture.status$.send(.ready)
    try await Task.sleep(for: .milliseconds(1))
    controller.command$.send(
      .switchCamera(cameraID: "cam-1")
    )
    try await Task.sleep(for: .milliseconds(1))

    #expect(capture.commands.count == 1)
    guard case let .switchCamera(cameraID) = capture.commands.first else {
      throw TestError.conditionFailed
    }
    #expect(cameraID == "cam-1")
    print(sut)
  }

  @Test
  func dropCommandIfCaptureIsNotReady() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

    controller.command$.send(
      .switchCamera(cameraID: "cam-1")
    )
    try await Task.sleep(for: .milliseconds(1))

    #expect(capture.commands.count == 0)
    print(sut)
  }

  @Test
  func routeBuffer() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

    controller.status$.send(.ready)
    try await Task.sleep(for: .milliseconds(1))
    let buffer = BufferWrapper.init(buffer: "Dummy", typeHint: .data(class: "String"))

    capture.buffer$.send(buffer)
    try await Task.sleep(for: .milliseconds(1))

    let buffers = await controller.actor.buffers
    #expect(buffers.count == 1)
    #expect(buffers.first?.buffer as? String == "Dummy")
    print(sut)
  }

  @Test
  func dropBufferIfControllerIsNotReady() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

    try await Task.sleep(for: .milliseconds(1))
    let buffer = BufferWrapper.init(buffer: "Dummy", typeHint: .data(class: "String"))

    capture.buffer$.send(buffer)
    try await Task.sleep(for: .milliseconds(1))

    let buffers = await controller.actor.buffers
    #expect(buffers.count == 0)
    print(sut)
  }

  @Test
  func unbindOnCaptureStatusChannelClose() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

    await confirmation { confirmation in
      Task.detached {
        capture.status$.send(completion: .finished)
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
  }

  @Test
  func unbindOnControllerStatusChannelClose() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

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
  }

  @Test
  func routeEventIfControllerIsReady() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

    controller.status$.send(.ready)
    try await Task.sleep(for: .milliseconds(1))
    capture.event$.send(.photoCaptured)
    try await Task.sleep(for: .milliseconds(1))

    let events = await controller.actor.events
    #expect(events.count == 1)
    guard case .photoCaptured = events.first else {
      throw TestError.conditionFailed
    }
    print(sut)
  }

  @Test
  func dropEventIfControllerIsNotReady() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

    capture.event$.send(.photoCaptured)
    try await Task.sleep(for: .milliseconds(1))

    let events = await controller.actor.events
    #expect(events.count == 0)
    print(sut)
  }

  @Test
  func routeInitialState() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    var update = CaptureServiceState()
    update.availableConfigurationCommands.lockWhiteBalanceWithGrayWorld = true
    update.camera = .init(id: "cam1", name: "front cam", position: .builtInFront)
    update.configuration.isHDRon = true
    update.capabilities.exposureModes = [.auto, .locked]
    capture.state$.send(update)
    #expect(capture.state == update)
    var sut: CaptureServiceClientBinding?
    var received = CaptureServiceState()

    #expect(received != update)
    let completer = await Completer<Void>()
    await controller.setOnUpdate { updates in
      if updates.count == 4 {
        Task {
          await completer.resume()
        }
      }
    }
    sut = await CaptureServiceClientBinding(client: controller, service: capture)
    controller.status$.send(.ready)
    await completer.result()
    let updates = await controller.actor.updates
    received.update(updates)
    #expect(received == update)
    print(sut!)
  }

  @Test
  func updateCameraIfControllerIsReady() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)
    var update = CaptureServiceState()
    update.availableConfigurationCommands.lockWhiteBalanceWithGrayWorld = true
    update.camera = .init(id: "cam1", name: "front cam", position: .builtInFront)
    update.configuration.isHDRon = true
    update.capabilities.exposureModes = [.auto, .locked]
    var received = update
    capture.state$.send(update)
    controller.status$.send(.ready)
    let preparation = await Completer<Void>()
    await controller.setOnUpdate { updates in
      if updates.count >= 4 {
        Task {
          await preparation.resume()
        }
      }
    }
    await preparation.result()

    let main = await Completer<Void>()
    await controller.setOnUpdate { updates in
      if updates.count >= 5 {
        Task {
          await main.resume()
        }
      }
    }
    update.camera = .init(id: "cam2", name: "back cam", position: .builtInBack)
    capture.state$.send(update)
    await main.result()

    let updates = await controller.actor.updates
    let last = updates.last!
    guard case .cameraDescriptor(_) = last else {
      throw TestError.conditionFailed
    }
    received.update(last)
    #expect(received == update)
    print(sut)
  }

  @Test
  func reportReadyOnBothReady() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

    let completer = await TimeoutThrowingCompleter<Void>(waitFor: .seconds(1))
    var values = [NodeStatus]()
    var bag = Set<AnyCancellable>()
    (await sut.onStatus).nonSendable.sink { status in
      values.append(status)
      if case .ready = status {
        Task {
          await completer.resume()
        }
      }
    }.store(in: &bag)
    capture.status$.send(.ready)
    controller.status$.send(.ready)

    try await completer.result()

    #expect(values == [.preparing, .ready])
  }

  @Test
  func unbindOnCancelStatus() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

    var outError: Error?
    await confirmation { confirmation in
      Task.detached {
        capture.status$.send(.ready)
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
