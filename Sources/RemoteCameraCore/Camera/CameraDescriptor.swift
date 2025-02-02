public struct CameraDescriptor: Sendable {
  public let id: String
  public let name: String
  public let position: CameraPosition

  public init(id: String, name: String, position: CameraPosition) {
    self.id = id
    self.name = name
    self.position = position
  }
}
