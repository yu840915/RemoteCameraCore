public enum CameraHubCommands: Sendable {
  case requestCapture(args: CaptureServiceArguments)
}

public struct CaptureServiceArguments: Sendable {
  public let camera: CameraDescriptor
  public init(camera: CameraDescriptor) {
    self.camera = camera
  }
}
