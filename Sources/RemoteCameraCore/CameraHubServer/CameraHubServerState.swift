public struct CameraHubServerState: Sendable {
  public internal(set) var requests: [ControlRequest] = []
  public internal(set) var isAdvertising: Bool = false
  public internal(set) var connectedControllers: [CameraControllerDescriptor] = []
}
