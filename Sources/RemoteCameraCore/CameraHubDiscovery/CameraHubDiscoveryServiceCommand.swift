public enum CameraHubDiscoveryServiceCommand: Sendable {
  case requestHub(args: CameraHubServiceArguments)
  case start
  case stop
}

public struct CameraHubServiceArguments: Sendable {
  public let hub: CameraHubDescriptor
  public init(hub: CameraHubDescriptor) {
    self.hub = hub
  }
}

public enum CameraHubDiscoveryServiceRemoteCommand: Sendable {
  case invite(ControlRequest)
}
