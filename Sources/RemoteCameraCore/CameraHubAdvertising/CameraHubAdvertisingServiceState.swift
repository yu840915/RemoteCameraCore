public struct CameraHubAdvertisingServiceState: Sendable {
  public var requests: [ControlRequest] = []
  public var isRunning: Bool = false

  public init() {}
}

public struct ControlRequest: Sendable {
  public let id: String
  public let name: String
  public init(id: String, name: String) {
    self.id = id
    self.name = name
  }
}
