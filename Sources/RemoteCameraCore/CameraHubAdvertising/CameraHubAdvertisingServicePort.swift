import CameraCore
import Combine

public protocol CameraHubAdvertisingServicePort: StateServiceClientPort
where
  State == CameraHubAdvertisingServiceState,
  Event == CameraHubAdvertisingServiceEvent,
  Command == CameraHubAdvertisingServiceCommand
{}
