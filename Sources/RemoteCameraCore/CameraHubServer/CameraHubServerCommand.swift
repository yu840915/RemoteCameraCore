public enum CameraHubServiceCommand: Sendable {
  case startAdvertising
  case stopAdvertising
  case acceptRequest(request: ControlRequest)
  case disconnect(controller: CameraControllerDescriptor)
}
