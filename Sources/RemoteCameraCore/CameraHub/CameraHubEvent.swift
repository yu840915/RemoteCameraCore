public enum CameraHubEvent: Sendable {
  case capture(capture: any CaptureServicePort)
}

public enum CameraHubRemoteEvent: Sendable {
  case captureChannelInfo(info: CaptureChannelInfo)
}

public struct CaptureChannelInfo: Sendable {
  public let channelID: MessageChannelID

  public init(channelID: MessageChannelID) {
    self.channelID = channelID
  }
}
