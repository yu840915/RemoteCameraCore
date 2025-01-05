import AsyncUtils
import CameraCore
import Combine
import Testing

@testable import RemoteCameraCore

@Suite("Hub controller binding tests")
struct CameraHubControllerBindingTests {
  @Test
  func routeCommand() async throws {
    var commands: [CameraHubCommands] = []
    var bag = Set<AnyCancellable>()
    let hub = MockHub()
    let controller = MockController()
    let sut = CameraHubControllerBinding(hub: hub, controller: controller)

    try await confirmation { called in
      hub.onCommands.sink { command in
        commands.append(command)
        called()
      }.store(in: &bag)
      controller.command$.nonSendable.send(
        .requestCapture(
          args: CaptureServiceArguments(
            camera: CameraDescriptor(
              id: "mockCamera",
              name: "Camera",
              position: .external
            )
          )
        )
      )
      try await Task.sleep(nanoseconds: 100_000)
    }

    #expect(commands.count == 1)
    print(sut)
  }

  @Test
  func routeEvent() async throws {
    var events: [CameraHubEvent] = []
    var bag = Set<AnyCancellable>()
    let hub = MockHub()
    let controller = MockController()
    let capture = MockCapture()
    let sut = CameraHubControllerBinding(hub: hub, controller: controller)

    try await confirmation { called in
      controller.onEvent.sink {
        _ in
      } receiveValue: { event in
        events.append(event)
        called()
      }.store(in: &bag)
      hub.event$.nonSendable.send(.capture(capture: capture))
      try await Task.sleep(nanoseconds: 100_000)
    }

    #expect(events.count == 1)
    if case let .capture(val) = events.first,
      let captureFromEvent = val as? MockCapture
    {
      #expect(capture === captureFromEvent)
    } else {
      assertionFailure()
    }
    print(sut)
  }

  @Test
  func routeState() async throws {
    var states: [CameraHubState] = []
    var bag = Set<AnyCancellable>()
    let hub = MockHub()
    let controller = MockController()
    let camera = CameraDescriptor(id: "mockCamera", name: "Camera", position: .external)
    var sut: CameraHubControllerBinding?

    try await confirmation("State update", expectedCount: 3) { called in
      controller.onState.sink {
        _ in
      } receiveValue: { state in
        states.append(state)
        called()
      }.store(in: &bag)
      sut = CameraHubControllerBinding(hub: hub, controller: controller)
      var value = hub.state$.nonSendable.value
      try await Task.sleep(nanoseconds: 1)
      value.name = "New name"
      hub.state$.nonSendable.send(value)
      try await Task.sleep(nanoseconds: 1)
      value.cameras = [camera]
      hub.state$.nonSendable.send(value)
      try await Task.sleep(nanoseconds: 100_000)
    }

    #expect(states.map { $0.id } == ["mockHub", "mockHub", "mockHub"])
    #expect(states.map { $0.name } == ["", "New name", "New name"])
    #expect(states.map { $0.cameras.count } == [0, 0, 1])
    print(sut!)
  }

  @Test
  func propagateEventChannelError() async throws {
    var errors: [Error] = []
    var bag = Set<AnyCancellable>()
    let hub = MockHub()
    let controller = MockController()
    let sut = CameraHubControllerBinding(hub: hub, controller: controller)

    try await confirmation { called in
      controller.onError.sink { error in
        errors.append(error)
        called()
      }.store(in: &bag)
      hub.event$.nonSendable.send(completion: .failure(MockError()))
      try await Task.sleep(nanoseconds: 100_000)
    }

    #expect(errors.count == 1)
    print(sut)
  }

  @Test
  func reportErrorOnEventChannelClose() async throws {
    var errors: [Error] = []
    var bag = Set<AnyCancellable>()
    let hub = MockHub()
    let controller = MockController()
    let sut = CameraHubControllerBinding(hub: hub, controller: controller)

    try await confirmation { called in
      controller.onError.sink { error in
        errors.append(error)
        called()
      }.store(in: &bag)
      hub.event$.nonSendable.send(completion: .finished)
      try await Task.sleep(nanoseconds: 100_000)
    }

    #expect(errors.count == 1)
    print(sut)
  }

  @Test
  func reportErrorOnStateChannelClose() async throws {
    var errors: [Error] = []
    var bag = Set<AnyCancellable>()
    let hub = MockHub()
    let controller = MockController()
    let sut = CameraHubControllerBinding(hub: hub, controller: controller)

    try await confirmation { called in
      controller.onError.sink { error in
        errors.append(error)
        called()
      }.store(in: &bag)
      hub.state$.nonSendable.send(completion: .finished)
      try await Task.sleep(nanoseconds: 100_000)
    }

    #expect(errors.count == 1)
    print(sut)
  }
}

struct MockError: Error {}

final class MockController: CameraHubControllerPort {
  var onCommand: any Publisher<CameraCore.CameraHubCommands, Never> {
    command$.nonSendable
  }

  let command$ = NonSendable(
    PassthroughSubject<CameraHubCommands, Never>()
  )

  let state$ = NonSendable(
    PassthroughSubject<CameraHubState, any Error>()
  )

  let event$ = NonSendable(
    PassthroughSubject<CameraHubEvent, any Error>()
  )

  let error$ = NonSendable(
    PassthroughSubject<Error, Never>()
  )

  var onState: any Publisher<CameraCore.CameraHubState, any Error> {
    state$.nonSendable
  }

  var onEvent: any Publisher<CameraCore.CameraHubEvent, any Error> {
    event$.nonSendable
  }

  var onError: any Publisher<Error, Never> {
    error$.nonSendable
  }

  func update(_ state: CameraHubState) async {
    state$.nonSendable.send(state)
  }

  func notify(_ event: CameraHubEvent) async {
    event$.nonSendable.send(event)
  }

  func onError(_ error: any Error) async {
    error$.nonSendable.send(error)
  }
}

final class MockHub: CameraHubServicePort {
  let id: String = "mockHub"

  let commands$ = NonSendable(PassthroughSubject<CameraHubCommands, Never>())

  var onCommands: any Publisher<CameraHubCommands, Never> {
    commands$.nonSendable
  }

  let state$ = NonSendable(
    CurrentValueSubject<CameraHubState, any Error>(
      CameraHubState(id: "mockHub")
    )
  )
  let event$ = NonSendable(
    PassthroughSubject<CameraHubEvent, any Error>()
  )

  var state: CameraCore.CameraHubState {
    state$.nonSendable.value
  }

  var onState: any Publisher<CameraCore.CameraHubState, any Error> {
    state$.nonSendable
  }

  var onEvent: any Publisher<CameraCore.CameraHubEvent, any Error> {
    event$.nonSendable
  }

  func perform(_ command: CameraCore.CameraHubCommands) async throws {
    commands$.nonSendable.send(command)
    print("Command sent")
  }
}

final class MockCapture: CaptureServicePort {
  var state: CameraCore.CaptureServiceState { CameraCore.CaptureServiceState() }

  var onState: any Publisher<CameraCore.CaptureServiceState, any Error> {
    PassthroughSubject<CameraCore.CaptureServiceState, any Error>()
  }

  var onEvent: any Publisher<CameraCore.CaptureServiceEvent, any Error> {
    PassthroughSubject<CameraCore.CaptureServiceEvent, any Error>()
  }

  var onCapturedBuffer: any Publisher<CameraCore.BufferWrapper, Never> {
    PassthroughSubject<CameraCore.BufferWrapper, Never>()
  }

  func perform(_ command: CameraCore.CaptureServiceCommand) async throws {
  }

}
