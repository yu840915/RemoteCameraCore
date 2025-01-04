import CameraCore
import Combine

public protocol RemoteCameraHubControllerPort: Sendable {
  var onCommand: any Publisher<CameraHubCommands, Never> { get }

  func update(_ state: CameraHubState) async
  func notify(_ event: CameraHubEvent) async
  func onError(_ error: Error) async
}
