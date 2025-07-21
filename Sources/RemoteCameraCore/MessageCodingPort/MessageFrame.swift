public typealias MessageChannelID = UInt16

public typealias MessageFrameEncoder<Data> = MessageEncodingServicePort<MessageFrame, Data>
public typealias MessageFrameDecoder<Data> = MessageDecodingServicePort<Data, MessageFrame>

public struct MessageFrame: Sendable {
  public enum MessageType: Sendable {
    case stateUpdate
    case event
    case command
    case error
  }

  public let channelID: MessageChannelID
  public let type: MessageType
  public let payload: [UInt8]

  public init(
    channelID: MessageChannelID,
    type: MessageType,
    payload: [UInt8]
  ) {
    self.channelID = channelID
    self.type = type
    self.payload = payload
  }
}

extension MessageFrame: CustomStringConvertible {
  public var description: String {
    "MessageFrame(channelID: \(channelID), type: \(type), payloadSize: \(payload.count) bytes)"
  }
}

extension MessageFrame.MessageType: CustomStringConvertible {
  public var description: String {
    switch self {
    case .command: "command"
    case .error: "error"
    case .event: "event"
    case .stateUpdate: "update"
    }
  }
}
