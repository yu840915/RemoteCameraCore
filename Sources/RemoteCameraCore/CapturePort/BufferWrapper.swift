public final class BufferWrapper: Sendable {
  public enum TypeHint: Sendable {
    case stillImage(class: String)
    case videoFrame(class: String)
    case compressedVideoFrame(class: String)
    case audio(class: String)
    case data(class: String)
  }

  public let typeHint: TypeHint
  public nonisolated(unsafe) let buffer: Any
  public init(buffer: Any, typeHint: TypeHint) {
    self.buffer = buffer
    self.typeHint = typeHint
  }
}
