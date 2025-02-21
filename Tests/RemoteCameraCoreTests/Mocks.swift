import Combine
import RemoteCameraCore

struct MockError: Error {}

final class DummyAdvertiserFactory: CameraHubAdvertiserFactoryPort, @unchecked Sendable {
  var adversisers: [DummyAdvertiser] = []
  func createHubAdvertiser(
    with hubDescriptor: RemoteCameraCore.CameraHubDescriptor
  )
    -> any RemoteCameraCore.CameraHubAdvertisingServicePort
  {
    let advertiser = DummyAdvertiser(hub: hubDescriptor)
    adversisers.append(advertiser)
    return advertiser
  }
}

final class DummyAdvertiser: CameraHubAdvertisingServicePort, @unchecked Sendable {
  var state$: CurrentValueSubject<RemoteCameraCore.CameraHubAdvertisingServiceState, any Error>
  var event$: PassthroughSubject<RemoteCameraCore.CameraHubAdvertisingServiceEvent, any Error>
  var state: RemoteCameraCore.CameraHubAdvertisingServiceState {
    state$.value
  }
  var onState: any Publisher<RemoteCameraCore.CameraHubAdvertisingServiceState, any Error> {
    state$
  }
  var onEvent: any Publisher<RemoteCameraCore.CameraHubAdvertisingServiceEvent, any Error> {
    event$
  }
  var commands: [RemoteCameraCore.CameraHubAdvertisingServiceCommand] = []
  let hub: RemoteCameraCore.CameraHubDescriptor
  init(hub: RemoteCameraCore.CameraHubDescriptor) {
    self.hub = hub
    state$ = CurrentValueSubject(.init())
    event$ = PassthroughSubject()
  }

  func perform(_ command: RemoteCameraCore.CameraHubAdvertisingServiceCommand) async throws {
    commands.append(command)
  }

}

final class DummyHubController: CameraHubClientPort, @unchecked Sendable {
  var controllerDescriptor: RemoteCameraCore.CameraControllerDescriptor
  var command$: PassthroughSubject<RemoteCameraCore.CameraHubCommand, any Error>
  var onCommand: any Publisher<RemoteCameraCore.CameraHubCommand, any Error> {
    command$
  }
  var updates: [RemoteCameraCore.CameraHubState] = []
  var events: [RemoteCameraCore.CameraHubEvent] = []
  var errors: [any Error] = []

  init(controllerDescriptor: RemoteCameraCore.CameraControllerDescriptor) {
    self.controllerDescriptor = controllerDescriptor
    command$ = PassthroughSubject()
  }

  func update(_ state: RemoteCameraCore.CameraHubState) async {
    updates.append(state)
  }

  func notify(_ event: RemoteCameraCore.CameraHubEvent) async {
    events.append(event)
  }

  func onError(_ error: any Error) async {
    errors.append(error)
  }

}

final class DummyCameraHub: CameraHubServicePort, @unchecked Sendable {
  var id: String
  var state$: CurrentValueSubject<RemoteCameraCore.CameraHubState, any Error>
  var event$: PassthroughSubject<RemoteCameraCore.CameraHubEvent, any Error>
  var state: RemoteCameraCore.CameraHubState {
    state$.value
  }
  var onState: any Publisher<RemoteCameraCore.CameraHubState, any Error> {
    state$
  }
  var onEvent: any Publisher<RemoteCameraCore.CameraHubEvent, any Error> {
    event$
  }
  var commands: [RemoteCameraCore.CameraHubCommand] = []

  init(state: RemoteCameraCore.CameraHubState) {
    id = state.id
    state$ = CurrentValueSubject(state)
    event$ = PassthroughSubject()
  }

  func perform(_ command: RemoteCameraCore.CameraHubCommand) async throws {
    commands.append(command)
  }
}

final class DummyCapture: CaptureServicePort, @unchecked Sendable {
  var onCapturedBuffer: any Publisher<RemoteCameraCore.BufferWrapper, Never> {
    Empty().eraseToAnyPublisher()
  }

  var state$: CurrentValueSubject<CaptureServiceState, any Error>
  var event$: PassthroughSubject<CaptureServiceEvent, any Error>
  var state: CaptureServiceState {
    state$.value
  }
  var onState: any Publisher<CaptureServiceState, any Error> {
    state$
  }
  var onEvent: any Publisher<CaptureServiceEvent, any Error> {
    event$
  }
  var commands: [CaptureServiceCommand] = []

  init(state: CaptureServiceState = .init()) {
    state$ = CurrentValueSubject(state)
    event$ = PassthroughSubject()
  }

  func perform(_ command: CaptureServiceCommand) async throws {
    commands.append(command)
  }
}
