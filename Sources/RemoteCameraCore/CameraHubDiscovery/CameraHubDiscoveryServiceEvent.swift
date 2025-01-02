import CameraCore

public enum CameraHubDiscoveryServiceEvent: Sendable {
  case cameraHub(hub: any CameraHubServicePort)
}
