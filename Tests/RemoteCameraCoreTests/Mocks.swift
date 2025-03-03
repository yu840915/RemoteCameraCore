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
  var error$: PassthroughSubject<Error, Never>
  var state: RemoteCameraCore.CameraHubAdvertisingServiceState {
    state$.value
  }
  var onState: any Publisher<RemoteCameraCore.CameraHubAdvertisingServiceState, any Error> {
    state$
  }
  var onEvent: any Publisher<RemoteCameraCore.CameraHubAdvertisingServiceEvent, any Error> {
    event$
  }
  var onError: any Publisher<Error, Never> {
    error$
  }
  var commands: [RemoteCameraCore.CameraHubAdvertisingServiceCommand] = []
  let hub: RemoteCameraCore.CameraHubDescriptor
  init(hub: RemoteCameraCore.CameraHubDescriptor) {
    self.hub = hub
    state$ = CurrentValueSubject(.init())
    event$ = PassthroughSubject()
    error$ = PassthroughSubject()
  }

  func perform(_ command: RemoteCameraCore.CameraHubAdvertisingServiceCommand) async throws {
    commands.append(command)
  }

}

final class DummyHubController: CameraHubClientPort, @unchecked Sendable {
  var controllerDescriptor: RemoteCameraCore.CameraControllerDescriptor
  var command$: PassthroughSubject<RemoteCameraCore.CameraHubCommand, any Error>
  var error$: PassthroughSubject<Error, Never>
  var onCommand: any Publisher<RemoteCameraCore.CameraHubCommand, any Error> {
    command$
  }
  var onError: any Publisher<Error, Never> {
    error$
  }
  let actor = ClientPortActor<
    RemoteCameraCore.CameraHubState,
    RemoteCameraCore.CameraHubEvent
  >()

  init(controllerDescriptor: RemoteCameraCore.CameraControllerDescriptor) {
    self.controllerDescriptor = controllerDescriptor
    command$ = PassthroughSubject()
    error$ = PassthroughSubject()
  }

  func update(_ state: RemoteCameraCore.CameraHubState) async {
    await actor.update(state)
  }

  func notify(_ event: RemoteCameraCore.CameraHubEvent) async {
    await actor.notify(event)

  }

  func report(_ error: any Error) async {
    await actor.onError(error)
  }

  func unbind(_ error: (any Error)?) async {
    await actor.unbind(error)
  }
}

final class DummyCameraHub: CameraHubServicePort, @unchecked Sendable {
  var id: String
  var state$: CurrentValueSubject<RemoteCameraCore.CameraHubState, any Error>
  var event$: PassthroughSubject<RemoteCameraCore.CameraHubEvent, any Error>
  var error$: PassthroughSubject<Error, Never>
  var state: RemoteCameraCore.CameraHubState {
    state$.value
  }
  var onState: any Publisher<RemoteCameraCore.CameraHubState, any Error> {
    state$
  }
  var onEvent: any Publisher<RemoteCameraCore.CameraHubEvent, any Error> {
    event$
  }
  var onError: any Publisher<Error, Never> {
    error$
  }
  var commands: [RemoteCameraCore.CameraHubCommand] = []

  init(state: RemoteCameraCore.CameraHubState) {
    id = state.id
    state$ = CurrentValueSubject(state)
    event$ = PassthroughSubject()
    error$ = PassthroughSubject()
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
  var error$: PassthroughSubject<Error, Never>
  var state: CaptureServiceState {
    state$.value
  }
  var onState: any Publisher<CaptureServiceState, any Error> {
    state$
  }
  var onEvent: any Publisher<CaptureServiceEvent, any Error> {
    event$
  }
  var onError: any Publisher<any Error, Never> {
    error$
  }
  var commands: [CaptureServiceCommand] = []

  init(state: CaptureServiceState = .init()) {
    state$ = CurrentValueSubject(state)
    event$ = PassthroughSubject()
    error$ = PassthroughSubject()
  }

  func perform(_ command: CaptureServiceCommand) async throws {
    commands.append(command)
  }
}

final class DummyCaptureController: CaptureClientPort, @unchecked Sendable {
  var command$: PassthroughSubject<RemoteCameraCore.CaptureServiceCommand, any Error>
  var error$: PassthroughSubject<Error, Never>
  var onCommand: any Publisher<RemoteCameraCore.CaptureServiceCommand, any Error> {
    command$
  }
  var onError: any Publisher<Error, Never> {
    error$
  }
  let actor = ClientPortActor<
    RemoteCameraCore.CaptureServiceStateUpdateMessage,
    RemoteCameraCore.CaptureServiceEvent
  >()

  init() {
    command$ = PassthroughSubject()
    error$ = PassthroughSubject()
  }

  func setOnUpdate(_ onUpdate: @Sendable @escaping ([State]) -> Void) async {
    await actor.setOnUpdate(onUpdate)
  }

  func update(_ state: RemoteCameraCore.CaptureServiceStateUpdateMessage) async {
    await actor.update(state)
  }

  func notify(_ event: RemoteCameraCore.CaptureServiceEvent) async {
    await actor.notify(event)
  }

  func report(_ error: any Error) async {
    await actor.onError(error)
  }

  func unbind(_ error: (any Error)?) async {
    await actor.unbind(error)
  }
}

actor ClientPortActor<State, Event>
where State: Sendable, Event: Sendable {
  var updates: [State] = []
  var onUpdate: (([State]) -> Void)?
  var events: [Event] = []
  var errors: [any Error] = []
  var unbindInvocation: UnbindInvocation?

  func setOnUpdate(_ onUpdate: @Sendable @escaping ([State]) -> Void) {
    self.onUpdate = onUpdate
  }

  func update(_ state: State) {
    updates.append(state)
    onUpdate?(updates)
  }

  func notify(_ event: Event) {
    events.append(event)
  }

  func onError(_ error: any Error) {
    errors.append(error)
  }

  func unbind(_ error: (any Error)?) {
    guard unbindInvocation == nil else {
      fatalError("unbind called more than once")
    }
    if let error = error {
      unbindInvocation = .error(error)
    } else {
      unbindInvocation = .finished
    }
  }
}

enum UnbindInvocation {
  case finished
  case error(any Error)
}

actor CollectionActor<T: Sendable> {
  var values: [T] = []
  var onAppended: (([T]) -> Void)?
  func append(_ value: T) {
    values.append(value)
    onAppended?(values)
  }

  func setOnAppended(_ handler: @Sendable @escaping ([T]) -> Void) {
    onAppended = handler
  }

  func reset() {
    values = []
  }
}
