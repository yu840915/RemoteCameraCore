public protocol MessageDecodingServicePort<Data, Message>: Sendable {
  associatedtype Data: Sendable
  associatedtype Message: Sendable

  func decode(data: Data) throws -> Message
}
