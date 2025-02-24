import Combine

public protocol CaptureServicePort: StateServicePort, AnyObject
where
  State == CaptureServiceState,
  Event == CaptureServiceEvent,
  Command == CaptureServiceCommand
{
  var onCapturedBuffer: any Publisher<BufferWrapper, Never> { get }
}

extension CaptureServicePort {
  public typealias CommandEncoder<Data> = MessageEncodingServicePort<CaptureServiceCommand, Data>
  public typealias CommandDecoder<Data> = MessageDecodingServicePort<Data, CaptureServiceCommand>
  public typealias StateEncoder<Data> = MessageEncodingServicePort<
    CaptureServiceStateUpdateMessage, Data
  >
  public typealias StateDecoder<Data> = MessageDecodingServicePort<
    Data, CaptureServiceStateUpdateMessage
  >
  public typealias EventEncoder<Data> = MessageEncodingServicePort<CaptureServiceEvent, Data>
  public typealias EventDecoder<Data> = MessageDecodingServicePort<Data, CaptureServiceEvent>
}
