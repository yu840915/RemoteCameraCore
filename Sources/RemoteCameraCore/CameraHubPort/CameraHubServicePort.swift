import Combine

public protocol CameraHubServicePort: StateServicePort
where
    State == CameraHubState,
    Event == CameraHubEvent,
    Command == CameraHubCommands
{
    var id: String { get }
}

public struct CameraHubServiceCoders {
    public typealias CommandEncoder<Data> = MessageEncodingServicePort<CameraHubCommands, Data>
    public typealias CommandDecoder<Data> = MessageDecodingServicePort<Data, CameraHubCommands>
    public typealias StateEncoder<Data> = MessageEncodingServicePort<CameraHubState, Data>
    public typealias StateDecoder<Data> = MessageDecodingServicePort<Data, CameraHubState>
    public typealias EventEncoder<Data> = MessageEncodingServicePort<CameraHubRemoteEvent, Data>
    public typealias EventDecoder<Data> = MessageDecodingServicePort<Data, CameraHubRemoteEvent>
}
