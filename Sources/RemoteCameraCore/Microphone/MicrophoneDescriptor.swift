public struct MicrophoneDescriptor: Sendable, Equatable {
  public let id: String
  public let name: String

  public init(id: String, name: String) {
    self.id = id
    self.name = name
  }
}

extension MicrophoneDescriptor: CustomStringConvertible {
  public var description: String {
    return "Camera(id: \(id), name: \(name)"
  }
}
