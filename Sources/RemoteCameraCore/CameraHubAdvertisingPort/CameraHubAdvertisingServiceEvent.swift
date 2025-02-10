public enum CameraHubAdvertisingServiceEvent: Sendable {
  case cameraHubClient(any CameraHubClientPort)
}

public enum CameraHubAdvertisingServiceRemoteEvent: Sendable {
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
