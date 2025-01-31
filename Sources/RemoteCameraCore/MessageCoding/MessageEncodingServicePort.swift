public protocol MessageEncodingServicePort<Message, Data>: Sendable {
  associatedtype Data: Sendable
  associatedtype Message: Sendable

  func encode(message: Message) throws -> Data
}
