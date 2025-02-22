import AsyncUtils
import RemoteCameraCore
import Testing

struct CaptureServiceClientBindingTests {
  @Test
  func routeCommand() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

    controller.command$.send(
      .swithCamera(cameraID: "cam-1")
    )
    try await Task.sleep(for: .milliseconds(1))

    #expect(capture.commands.count == 1)
    guard case let .swithCamera(cameraID) = capture.commands.first else {
      throw TestError.conditionFailed
    }
    #expect(cameraID == "cam-1")
    print(sut)
  }

  @Test
  func unbindOnCommandChannelClose() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

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

    guard case .finished = await controller.actor.unbindInvocation else {
      throw TestError.conditionFailed
    }
  }

  @Test
  func unbindOnCommandChannelError() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

    await confirmation { confirmation in
      Task.detached {
        controller.command$.send(completion: .failure(TestError.conditionFailed))
      }

      do {
        try await sut.waitUnbound()
      } catch {
        confirmation()
      }
    }

    guard case .finished = await controller.actor.unbindInvocation else {
      throw TestError.conditionFailed
    }
  }

  @Test
  func routeEvent() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

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
  func reportErrorOnEventChannelClose() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

    await confirmation { confirmation in
      Task.detached {
        capture.event$.send(completion: .finished)
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
  func propagateEventChannelError() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

    await confirmation { confirmation in
      Task.detached {
        capture.event$.send(completion: .failure(TestError.conditionFailed))
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
  func reportErrorOnStateChannelClose() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

    await confirmation { confirmation in
      Task.detached {
        capture.state$.send(completion: .finished)
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
  func propagateStateChannelError() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)

    await confirmation { confirmation in
      Task.detached {
        capture.state$.send(completion: .failure(TestError.conditionFailed))
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
  func routeInitialState() async throws {
    let capture = DummyCapture()
    let controller = DummyCaptureController()
    let sut = await CaptureServiceClientBinding(client: controller, service: capture)
    var update = CaptureServiceState()
    update.availableConfigurationCommands.lockWhiteBalanceWithGrayWorld = true
    update.camera = .init(id: "cam1", name: "front cam", position: .builtInFront)
    update.configuration.isHDRon = true
    update.capabilities.exposureModes = [.auto, .locked]
    var received = CaptureServiceState()

    #expect(received != update)
    await confirmation(nil, expectedCount: 4) { confirmation in
      let completer = await Completer<Void>()
      Task.detached { [update] in
        capture.state$.send(update)
      }
      await controller.setOnUpdate { updates in
        confirmation()
        if updates.count == 4 {
          Task {
            await completer.resume()
          }
        }
      }
      await completer.result()
    }
    let updates = await controller.actor.updates
    received.update(updates)
    #expect(received == update)
    print(sut)
  }

  @Test
  func updateCamera() async throws {
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
}
