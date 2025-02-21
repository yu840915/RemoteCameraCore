public enum CameraHubCommand: Sendable {
  case requestCapture(args: CaptureServiceArguments)
}

public struct CaptureServiceArguments: Sendable, Equatable {
  public let camera: CameraDescriptor
  public init(camera: CameraDescriptor) {
    self.camera = camera
  }
}
