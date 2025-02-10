import Combine

public protocol CameraHubAdvertisingServicePort: StateServicePort
where
  State == CameraHubAdvertisingServiceState,
  Event == CameraHubAdvertisingServiceEvent,
  Command == CameraHubAdvertisingServiceCommand
{}

public struct CameraHubAdvertisingServiceCoders {
  public typealias EventEncoder<Data> = MessageEncodingServicePort<
    CameraHubAdvertisingServiceRemoteEvent, Data
  >
  public typealias EventDecoder<Data> = MessageDecodingServicePort<
    Data, CameraHubAdvertisingServiceRemoteEvent
  >
}
