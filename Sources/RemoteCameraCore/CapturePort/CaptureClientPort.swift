public protocol CaptureClientPort: StateServiceClientPort
where
  State == CaptureServiceStateUpdateMessage,
  Event == CaptureServiceEvent,
  Command == CaptureServiceCommand
{
  func receive(_ buffer: BufferWrapper) async
}
