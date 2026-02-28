public final class BufferWrapper: Sendable {
  public enum TypeHint: Sendable {
    case stillImage(class: String)
    case videoFrame(class: String)
    case compressedVideoFrame(class: String)
    case audio(class: String)
    case data(class: String)
  }

  public let typeHint: TypeHint
  public let channel: Int?
  public let imageOrientation: ImageOrientation?
  public let inputDeviceOrientation: DeviceOrientation?
  public nonisolated(unsafe) let buffer: Any
  public init(
    buffer: Any,
    typeHint: TypeHint,
    channel: Int? = nil,
    imageOrientation: ImageOrientation? = nil,
    inputDeviceOrientation: DeviceOrientation? = nil,
  ) {
    self.buffer = buffer
    self.typeHint = typeHint
    self.channel = channel
    self.imageOrientation = imageOrientation
    self.inputDeviceOrientation = inputDeviceOrientation
  }
}
