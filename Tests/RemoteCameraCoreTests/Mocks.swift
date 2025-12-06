import Combine
import RemoteCameraCore

struct MockError: Error {}

final class DummyAdvertiserFactory: CameraHubAdvertiserFactoryPort, @unchecked Sendable {
  var adversisers: [DummyAdvertiser] = []
  func createHubAdvertiser(
    with hubDescriptor: CameraHubDescriptor
  )
    -> any CameraHubAdvertisingServicePort
  {
    let advertiser = DummyAdvertiser(hub: hubDescriptor)
    adversisers.append(advertiser)
    return advertiser
  }
}

final class DummyAdvertiser: CameraHubAdvertisingServicePort, @unchecked Sendable {
  var status$ = CurrentValueSubject<NodeStatus, Never>(.preparing)
  var state$: CurrentValueSubject<CameraHubAdvertisingServiceState, Never>
  var event$: PassthroughSubject<CameraHubAdvertisingServiceEvent, Never>
  var error$: PassthroughSubject<Error, Never>
  var onStatus: AnyPublisher<NodeStatus, Never> {
    status$.eraseToAnyPublisher()
  }
  var state: CameraHubAdvertisingServiceState {
    state$.value
  }
  var onState: AnyPublisher<CameraHubAdvertisingServiceState, Never> {
    state$.eraseToAnyPublisher()
  }
  var onEvent: AnyPublisher<CameraHubAdvertisingServiceEvent, Never> {
    event$.eraseToAnyPublisher()
  }
  var onError: AnyPublisher<Error, Never> {
    error$.eraseToAnyPublisher()
  }
  var commands: [CameraHubAdvertisingServiceCommand] = []
  let hub: CameraHubDescriptor
  init(hub: CameraHubDescriptor) {
    self.hub = hub
    state$ = CurrentValueSubject(.init())
    event$ = PassthroughSubject()
    error$ = PassthroughSubject()
  }

  func perform(_ command: CameraHubAdvertisingServiceCommand) async throws {
    commands.append(command)
  }

}

final class DummyHubController: CameraHubClientPort, @unchecked Sendable {
  var controllerDescriptor: CameraControllerDescriptor
  var status$: CurrentValueSubject<NodeStatus, Never>
  var command$: PassthroughSubject<CameraHubCommand, Never>
  var error$: PassthroughSubject<Error, Never>
  var onStatus: AnyPublisher<NodeStatus, Never> {
    status$.eraseToAnyPublisher()
  }
  var onCommand: AnyPublisher<CameraHubCommand, Never> {
    command$.eraseToAnyPublisher()
  }
  var onError: AnyPublisher<Error, Never> {
    error$.eraseToAnyPublisher()
  }
  let actor = ClientPortActor<
    CameraHubState,
    CameraHubEvent
  >()

  init(controllerDescriptor: CameraControllerDescriptor) {
    self.controllerDescriptor = controllerDescriptor
    status$ = CurrentValueSubject(.preparing)
    command$ = PassthroughSubject()
    error$ = PassthroughSubject()
  }

  func update(_ state: CameraHubState) async {
    await actor.update(state)
  }

  func notify(_ event: CameraHubEvent) async {
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
  var status$: CurrentValueSubject<NodeStatus, Never>
  var state$: CurrentValueSubject<CameraHubState, Never>
  var event$: PassthroughSubject<CameraHubEvent, Never>
  var error$: PassthroughSubject<Error, Never>
  var onStatus: AnyPublisher<NodeStatus, Never> {
    status$.eraseToAnyPublisher()
  }
  var state: CameraHubState {
    state$.value
  }
  var onState: AnyPublisher<CameraHubState, Never> {
    state$.eraseToAnyPublisher()
  }
  var onEvent: AnyPublisher<CameraHubEvent, Never> {
    event$.eraseToAnyPublisher()
  }
  var onError: AnyPublisher<Error, Never> {
    error$.eraseToAnyPublisher()
  }
  var commands: [CameraHubCommand] = []

  init(state: CameraHubState) {
    id = state.id
    status$ = CurrentValueSubject(.preparing)
    state$ = CurrentValueSubject(state)
    event$ = PassthroughSubject()
    error$ = PassthroughSubject()
  }

  func perform(_ command: CameraHubCommand) async throws {
    commands.append(command)
  }
}

final class DummyCapture: CaptureServicePort, @unchecked Sendable {
  var onCapturedBuffer: AnyPublisher<BufferWrapper, Never> {
    buffer$.eraseToAnyPublisher()
  }
  var buffer$: PassthroughSubject<BufferWrapper, Never>

  var status$: CurrentValueSubject<NodeStatus, Never>
  var state$: CurrentValueSubject<CaptureServiceState, Never>
  var event$: PassthroughSubject<CaptureServiceEvent, Never>
  var error$: PassthroughSubject<Error, Never>
  var state: CaptureServiceState {
    state$.value
  }
  var onStatus: AnyPublisher<NodeStatus, Never> {
    status$.eraseToAnyPublisher()
  }
  var onState: AnyPublisher<CaptureServiceState, Never> {
    state$.eraseToAnyPublisher()
  }
  var onEvent: AnyPublisher<CaptureServiceEvent, Never> {
    event$.eraseToAnyPublisher()
  }
  var onError: AnyPublisher<Error, Never> {
    error$.eraseToAnyPublisher()
  }
  var commands: [CaptureServiceCommand] = []

  init(state: CaptureServiceState = .init()) {
    buffer$ = PassthroughSubject()
    status$ = CurrentValueSubject(.preparing)
    state$ = CurrentValueSubject(state)
    event$ = PassthroughSubject()
    error$ = PassthroughSubject()
  }

  func perform(_ command: CaptureServiceCommand) async throws {
    commands.append(command)
  }
}

final class DummyCaptureController: CaptureClientPort, @unchecked Sendable {
  var status$: CurrentValueSubject<NodeStatus, Never>
  var command$: PassthroughSubject<CaptureServiceCommand, Never>
  var error$: PassthroughSubject<Error, Never>
  var onStatus: AnyPublisher<NodeStatus, Never> {
    status$.eraseToAnyPublisher()
  }
  var onCommand: AnyPublisher<CaptureServiceCommand, Never> {
    command$.eraseToAnyPublisher()
  }
  var onError: AnyPublisher<Error, Never> {
    error$.eraseToAnyPublisher()
  }
  let actor = ClientPortActor<
    CaptureServiceStateUpdateMessage,
    CaptureServiceEvent
  >()

  init() {
    status$ = CurrentValueSubject(.preparing)
    command$ = PassthroughSubject()
    error$ = PassthroughSubject()
  }

  func setOnUpdate(_ onUpdate: @Sendable @escaping ([State]) -> Void) async {
    await actor.setOnUpdate(onUpdate)
  }

  func update(_ state: CaptureServiceStateUpdateMessage) async {
    await actor.update(state)
  }

  func notify(_ event: CaptureServiceEvent) async {
    await actor.notify(event)
  }

  func report(_ error: any Error) async {
    await actor.onError(error)
  }

  func unbind(_ error: (any Error)?) async {
    await actor.unbind(error)
  }

  func receive(_ buffer: BufferWrapper) async {
    await actor.receive(buffer)
  }
}

actor ClientPortActor<State, Event>
where State: Sendable, Event: Sendable {
  var updates: [State] = []
  var onUpdate: (([State]) -> Void)?
  var events: [Event] = []
  var errors: [any Error] = []
  var buffers: [BufferWrapper] = []
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

  func receive(_ buffer: BufferWrapper) {
    buffers.append(buffer)
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
