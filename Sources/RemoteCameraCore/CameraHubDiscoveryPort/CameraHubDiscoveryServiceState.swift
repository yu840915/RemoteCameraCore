public struct CameraHubDiscoveryServiceState: Sendable, Equatable {
  public var hubs: [CameraHubDescriptor] = []
  public var isRunning: Bool = false

  public init() {}
}
