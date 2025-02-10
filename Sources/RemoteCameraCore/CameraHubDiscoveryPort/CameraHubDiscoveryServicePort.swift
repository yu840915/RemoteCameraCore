import Combine

public protocol CameraHubDiscoveryServicePort: StateServicePort
where
  State == CameraHubDiscoveryServiceState,
  Event == CameraHubDiscoveryServiceEvent,
  Command == CameraHubDiscoveryServiceCommand
{}

public struct CameraHubDiscoveryServiceCoders {
  public typealias CommandEncoder<Data> = MessageEncodingServicePort<
    CameraHubDiscoveryServiceRemoteCommand, Data
  >
  public typealias CommandDecoder<Data> = MessageDecodingServicePort<
    Data, CameraHubDiscoveryServiceRemoteCommand
  >
}
