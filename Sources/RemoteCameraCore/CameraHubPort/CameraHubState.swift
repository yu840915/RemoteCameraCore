public struct CameraHubState: Sendable, Equatable {
  public let id: String
  public var name: String = ""
  public var cameras: [CameraDescriptor] = []

  public init(id: String) {
    self.id = id
  }
}
