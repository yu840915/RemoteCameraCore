import CameraCore
import Combine

public protocol CameraHubDiscoveryServicePort: StateServiceClientPort
where
  State == CameraHubDiscoveryServiceState,
  Event == CameraHubDiscoveryServiceEvent,
  Command == CameraHubDiscoveryServiceCommand
{}
