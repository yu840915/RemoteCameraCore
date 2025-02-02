public enum CameraHubAdvertisingServiceCommand: Sendable {
  case acceptRequest(request: ControlRequest)
  case start
  case stop
}

public enum CameraHubAdvertisingServiceMessage: Sendable {
  case hubMessageChannel(CameraHubMessageChannelInfo)
}

public struct CameraHubMessageChannelInfo: Sendable {
  public let hub: CameraHubDescriptor
  public let channelID: MessageChannelID
  public init(hub: CameraHubDescriptor, channelID: MessageChannelID) {
    self.hub = hub
    self.channelID = channelID
  }
}
