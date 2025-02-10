public struct CameraHubDiscoveryServiceState: Sendable {
  public var hubs: [CameraHubDescriptor] = []
  public var isRunning: Bool = false

  public init() {}
}
