import CameraCore

public protocol MessageDecodingServicePort: EventServicePort
where
  Command == MessageDecodingServiceCommand<Data>,
  Event == MessageDecodingServiceEvent<Message>
{
  associatedtype Data: Sendable
  associatedtype Message: Sendable
}

public enum MessageDecodingServiceCommand<Data: Sendable>: Sendable {
  case decode(data: Data)
}

public enum MessageDecodingServiceEvent<Message: Sendable>: Sendable {
  case messageOutput(message: Message)
}
