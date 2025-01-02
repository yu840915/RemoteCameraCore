import CameraCore
import Combine

public protocol CameraHubAdvertisingServicePort: Sendable {
  var state: CameraHubDiscoveryServiceState { get }
  var onState: any Publisher<CameraHubAdvertisingServiceState, Error> { get }
  var onEvent: any Publisher<CameraHubAdvertisingServiceEvent, Error> { get }

  func perform(_ command: CameraHubAdvertisingServiceCommand) async throws
}
