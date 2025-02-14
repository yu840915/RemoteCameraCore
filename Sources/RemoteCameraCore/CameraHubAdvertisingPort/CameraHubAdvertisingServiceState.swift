public struct CameraHubAdvertisingServiceState: Sendable, Equatable {
  public var requests: [ControlRequest] = []
  public var isRunning: Bool = false

  public init() {}
}
