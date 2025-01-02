import CameraCore

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
