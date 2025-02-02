import Combine

public protocol CameraHubAdvertisingServicePort: StateServicePort
where
  State == CameraHubAdvertisingServiceState,
  Event == CameraHubAdvertisingServiceEvent,
  Command == CameraHubAdvertisingServiceCommand
{}
