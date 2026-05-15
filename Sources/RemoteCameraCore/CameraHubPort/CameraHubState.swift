public struct CameraHubState: Sendable, Equatable {
  public let id: String
  public var name: String
  public var cameras: [CameraDescriptor]
  public var microphones: [MicrophoneDescriptor]

  public init(
    id: String,
    name: String = "",
    cameras: [CameraDescriptor] = [],
    microphones: [MicrophoneDescriptor] = []
  ) {
    self.id = id
    self.name = name
    self.cameras = cameras
    self.microphones = microphones
  }
}

extension CameraHubState: CustomStringConvertible {
  public var description: String {
    "CameraHubState(id: \(id), name: \(name), cameras: \(cameras), microphones: \(microphones))"
  }
}
