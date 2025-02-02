public struct CameraHubState: Sendable {
  public let id: String
  public var name: String = ""
  public var cameras: [CameraDescriptor] = []

  public init(id: String) {
    self.id = id
  }
}
