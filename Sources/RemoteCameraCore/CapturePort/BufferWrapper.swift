public final class BufferWrapper: Sendable {
  public enum TypeHint: Sendable {
    case stillImage(class: String, info: MediaFileInfo)
    case videoFrame(class: String, info: VideoBufferInfo)
    case audioFrame(class: String)
    case compressedVideoFrame(class: String, info: VideoBufferInfo)
    case compressedAudioFrame(class: String)
    case audio(class: String, info: MediaFileInfo)
    case data(class: String)
    case video(class: String, info: MediaFileInfo)
  }

  public let typeHint: TypeHint
  public let channel: Int?
  public let inputDeviceDirection: DeviceDirection?
  public nonisolated(unsafe) let buffer: Any
  public init(
    buffer: Any,
    typeHint: TypeHint,
    channel: Int? = nil,
    inputDeviceDirection: DeviceDirection? = nil,
  ) {
    self.buffer = buffer
    self.typeHint = typeHint
    self.channel = channel
    self.inputDeviceDirection = inputDeviceDirection

  }
}

public enum VideoMirroring: Sendable {
  case none
  case horizontal
  case vertical
  case both
}
