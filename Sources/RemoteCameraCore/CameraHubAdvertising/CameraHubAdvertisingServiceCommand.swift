import CameraCore

public enum CameraHubAdvertisingServiceCommand: Sendable {
  case addCameraHub(descriptor: CameraHubDescriptor)
  case acceptRequest(request: ControlRequest)
  case start
  case stop
}
