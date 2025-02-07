public enum CameraHubAdvertisingServiceCommand: Sendable {
  case acceptRequest(request: ControlRequest)
  case start
  case stop
}
