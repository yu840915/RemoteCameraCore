import CameraCore

public protocol MessageEncodingServicePort: EventServicePort
where
  Command == MessageEncodingServiceCommand<Message>,
  Event == MessageEncodingServiceEvent<Data>
{
  associatedtype Data: Sendable
  associatedtype Message: Sendable
}

public enum MessageEncodingServiceCommand<Message: Sendable>: Sendable {
  case encode(message: Message)
}

public enum MessageEncodingServiceEvent<Data: Sendable>: Sendable {
  case dataOutput(data: Data)
}
