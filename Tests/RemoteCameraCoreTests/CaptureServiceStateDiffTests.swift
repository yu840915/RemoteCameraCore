import RemoteCameraCore
import Testing

struct CaptureServiceStateDiffTests {

  // MARK: - Nothing changed

  @Test
  func identicalStatesProduceNoMessages() {
    let state = CaptureServiceState.populated

    #expect(state.diff(from: state).isEmpty)
  }

  @Test
  func defaultStatesProduceNoMessages() {
    #expect(CaptureServiceState().diff(from: CaptureServiceState()).isEmpty)
  }

  // MARK: - One field at a time

  @Test("A changed field emits exactly its own message", arguments: FieldMutation.all)
  func changedFieldEmitsItsOwnMessage(_ mutation: FieldMutation) {
    let previous = CaptureServiceState()
    var current = previous
    mutation.apply(to: &current)

    #expect(current.diff(from: previous).map(\.kind) == [mutation.expectedKind])
  }

  @Test("An unchanged field is never re-sent", arguments: FieldMutation.all)
  func unchangedFieldIsNotResent(_ mutation: FieldMutation) {
    var previous = CaptureServiceState()
    mutation.apply(to: &previous)
    let current = previous

    #expect(current.diff(from: previous).isEmpty)
  }

  @Test("Applying a field's message reproduces the change", arguments: FieldMutation.all)
  func applyingMessageReproducesField(_ mutation: FieldMutation) {
    let previous = CaptureServiceState()
    var current = previous
    mutation.apply(to: &current)

    var rebuilt = previous
    rebuilt.update(current.diff(from: previous))

    #expect(rebuilt == current)
  }

  // MARK: - Many fields at once

  @Test
  func everyChangedFieldEmitsOneMessageEach() {
    let kinds = CaptureServiceState.populated
      .diff(from: CaptureServiceState())
      .map(\.kind)

    #expect(Set(kinds) == Set(MessageKind.allCases))
    #expect(kinds.count == Set(kinds).count, "a field was reported more than once")
  }

  @Test
  func onlyChangedFieldsAreReported() {
    let previous = CaptureServiceState.populated
    var current = previous
    current.mode = .timelapse
    current.configuration.zoomFactor = 4

    #expect(Set(current.diff(from: previous).map(\.kind)) == [.mode, .configuration])
  }

  // MARK: - Round trips

  @Test
  func diffRoundTripsBetweenTwoPopulatedStates() {
    let previous = CaptureServiceState.populated
    let current = CaptureServiceState.repopulated

    var rebuilt = previous
    rebuilt.update(current.diff(from: previous))

    #expect(rebuilt == current)
  }

  /// A client binding at `.ready` re-syncs by diffing against a default state, so this is the
  /// full-snapshot path.
  @Test
  func diffFromDefaultCarriesEveryNonDefaultField() {
    let current = CaptureServiceState.populated

    var rebuilt = CaptureServiceState()
    rebuilt.update(current.diff(from: CaptureServiceState()))

    #expect(rebuilt == current)
  }

  // MARK: - Known limitation

  /// `CaptureServiceStateUpdateMessage.cameraDescriptor` carries a non-optional descriptor, so a
  /// camera going away cannot be expressed on the wire and the remote controller keeps the last
  /// one it saw. Pinned deliberately — changing it means changing the message case and the
  /// protobuf mapping in NWRemoteCameraAdapter.
  @Test
  func clearingTheCameraEmitsNoCameraMessage() {
    var previous = CaptureServiceState()
    previous.camera = .back
    var current = previous
    current.camera = nil
    current.mode = .photo

    #expect(current.diff(from: previous).map(\.kind) == [.mode])
  }

  // MARK: - Exhaustiveness

  /// Fails when a stored property is added to `CaptureServiceState` without a matching entry
  /// here — which is the whole point of moving the diff onto the state type.
  @Test
  func mutationTableCoversEveryStoredProperty() {
    let stored = Set(
      Mirror(reflecting: CaptureServiceState()).children.compactMap(\.label)
    )
    let covered = Set(FieldMutation.all.map(\.label))

    #expect(
      stored == covered,
      """
      uncovered: \(stored.subtracting(covered).sorted()), \
      stale: \(covered.subtracting(stored).sorted())
      """
    )
  }
}

// MARK: - Message kinds

enum MessageKind: String, CaseIterable, Sendable {
  case cameraDescriptor
  case microphoneDescriptors
  case configuration
  case capabilities
  case availableModes
  case availableCommands
  case availableConfigurationCommands
  case captureTasks
  case recordingTasks
  case mode
}

extension CaptureServiceStateUpdateMessage {
  /// The case, without its payload, so tests can assert on what was sent without requiring
  /// `CaptureServiceStateUpdateMessage` to be `Equatable`.
  var kind: MessageKind {
    switch self {
    case .cameraDescriptor: .cameraDescriptor
    case .microphoneDescriptors: .microphoneDescriptors
    case .configuration: .configuration
    case .capabilities: .capabilities
    case .availableModes: .availableModes
    case .availableCommands: .availableCommands
    case .availableConfigurationCommands: .availableConfigurationCommands
    case .captureTasks: .captureTasks
    case .recordingTasks: .recordingTasks
    case .mode: .mode
    }
  }
}

// MARK: - One mutation per stored property

struct FieldMutation: Sendable, CustomStringConvertible {
  /// The stored property name, checked against `Mirror` so the table cannot drift.
  let label: String
  let expectedKind: MessageKind
  private let mutate: @Sendable (inout CaptureServiceState) -> Void

  init(
    _ label: String,
    _ expectedKind: MessageKind,
    _ mutate: @escaping @Sendable (inout CaptureServiceState) -> Void
  ) {
    self.label = label
    self.expectedKind = expectedKind
    self.mutate = mutate
  }

  func apply(to state: inout CaptureServiceState) {
    mutate(&state)
  }

  var description: String { label }
}

extension FieldMutation {
  static let all: [FieldMutation] = [
    .init("camera", .cameraDescriptor) { $0.camera = .back },
    .init("microphones", .microphoneDescriptors) { $0.microphones = [.builtIn] },
    .init("configuration", .configuration) { $0.configuration.zoomFactor = 2 },
    .init("capabilities", .capabilities) { $0.capabilities.torchModes = [.on, .off] },
    .init("availableConfigurationCommands", .availableConfigurationCommands) {
      $0.availableConfigurationCommands.setISO = true
    },
    .init("availableCommands", .availableCommands) { $0.availableCommands.capturePhoto = true },
    .init("availableModes", .availableModes) { $0.availableModes.photo = true },
    .init("captureTasks", .captureTasks) { $0.captureTasks = [.pending] },
    .init("recordingTasks", .recordingTasks) { $0.recordingTasks = [.video] },
    .init("mode", .mode) { $0.mode = .photo },
  ]
}

// MARK: - Fixtures

extension CameraDescriptor {
  static let back = CameraDescriptor(id: "back", name: "Back Camera", position: .builtInBack)
  static let front = CameraDescriptor(id: "front", name: "Front Camera", position: .builtInFront)
}

extension MicrophoneDescriptor {
  static let builtIn = MicrophoneDescriptor(id: "mic", name: "Built-in Microphone")
}

extension CaptureTaskInfo {
  static let pending = CaptureTaskInfo(id: "capture-1", startAt: .seconds(30))
}

extension RecordingTaskInfo {
  static let video = RecordingTaskInfo(
    id: "recording-1",
    startAt: .seconds(10),
    type: .video(VideoRecordingSettings(frameRate: 30))
  )

  static let timelapse = RecordingTaskInfo(
    id: "recording-2",
    startAt: .seconds(20),
    type: .timelapse(TimelapseRecordingSettings(interval: .seconds(1), frameRate: 30))
  )
}

extension CaptureServiceState {
  /// Every stored property away from its default, so a diff against `CaptureServiceState()`
  /// exercises all of them.
  static var populated: CaptureServiceState {
    var state = CaptureServiceState()
    FieldMutation.all.forEach { $0.apply(to: &state) }
    return state
  }

  /// `populated` with every stored property changed again, for two-way round trips.
  static var repopulated: CaptureServiceState {
    var state = CaptureServiceState()
    state.camera = .front
    state.microphones = []
    state.configuration.zoomFactor = 3
    state.capabilities.torchModes = [.auto]
    state.availableConfigurationCommands.enableAll()
    state.availableCommands.startVideoRecording = true
    state.availableModes.video = true
    state.captureTasks = []
    state.recordingTasks = [.timelapse]
    state.mode = .video
    return state
  }
}
