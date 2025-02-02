import Combine

public protocol CaptureServicePort: StateServicePort
where
  State == CaptureServiceState,
  Event == CaptureServiceEvent,
  Command == CaptureServiceCommand
{
  var onCapturedBuffer: any Publisher<BufferWrapper, Never> { get }
}
