public struct ControlRequest: Sendable, Equatable {
  public let controller: CameraControllerDescriptor
  public let hub: CameraHubDescriptor
  public let connectionSuite: ConnectionSuite

  public init(
    controller: CameraControllerDescriptor,
    hub: CameraHubDescriptor,
    connectionSuite: ConnectionSuite
  ) {
    self.controller = controller
    self.hub = hub
    self.connectionSuite = connectionSuite
  }
}

extension ControlRequest: CustomStringConvertible {
  public var description: String {
    "ControlRequest(controller: \(controller), hub: \(hub))"
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

extension CameraControllerDescriptor: CustomStringConvertible {
  public var description: String {
    "CameraControllerDescriptor(ID: \(id), name: \(name))"
  }
}
