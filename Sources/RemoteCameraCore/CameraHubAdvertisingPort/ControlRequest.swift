public struct ControlRequest: Sendable, Equatable {
  public let controller: CameraControllerDescriptor
  public let hub: CameraHubDescriptor
  public init(controller: CameraControllerDescriptor, hub: CameraHubDescriptor) {
    self.controller = controller
    self.hub = hub
  }
}

public struct CameraControllerDescriptor: Sendable, Equatable {
  public let id: String
  public let name: String
  public init(id: String, name: String) {
    self.id = id
    self.name = name
  }
}
