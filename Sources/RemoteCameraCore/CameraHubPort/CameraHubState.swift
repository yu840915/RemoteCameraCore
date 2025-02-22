public struct CameraHubState: Sendable, Equatable {
  public let id: String
  public var name: String
  public var cameras: [CameraDescriptor]

  public init(
    id: String,
    name: String = "",
    cameras: [CameraDescriptor] = []
  ) {
    self.id = id
    self.name = name
    self.cameras = cameras
  }
}
