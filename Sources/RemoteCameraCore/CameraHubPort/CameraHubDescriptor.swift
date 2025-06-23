public struct CameraHubDescriptor: Sendable, Equatable {
  public let id: String
  public let name: String

  public init(id: String, name: String) {
    self.id = id
    self.name = name
  }
}

extension CameraHubDescriptor: CustomStringConvertible {
  public var description: String {
    "CameraHubDescriptor(ID: \(id), name: \(name))"
  }
}
