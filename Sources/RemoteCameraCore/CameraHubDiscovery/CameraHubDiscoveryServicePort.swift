import Combine

public protocol CameraHubDiscoveryServicePort: StateServicePort
where
  State == CameraHubDiscoveryServiceState,
  Event == CameraHubDiscoveryServiceEvent,
  Command == CameraHubDiscoveryServiceCommand
{}
