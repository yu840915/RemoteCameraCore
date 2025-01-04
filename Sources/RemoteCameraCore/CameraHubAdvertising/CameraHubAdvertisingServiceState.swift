public struct CameraHubAdvertisingServiceState: Sendable {
  public var requests: [ControlRequest] = []
  public var isRunning: Bool = false

  public init() {}
}

