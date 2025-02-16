public enum CameraHubServerCommand: Sendable {
  case startAdvertising
  case stopAdvertising
  case acceptRequest(request: ControlRequest)
  case disconnect(controller: CameraControllerDescriptor)
}
