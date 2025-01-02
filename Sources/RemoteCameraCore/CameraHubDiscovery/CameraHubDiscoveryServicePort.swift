import Combine

public protocol CameraHubDiscoveryServicePort: Sendable {
  var state: CameraHubDiscoveryServiceState { get }
  var onState: any Publisher<CameraHubDiscoveryServiceState, Error> { get }
  var onEvent: any Publisher<CameraHubDiscoveryServiceEvent, Error> { get }
  func perform(_ command: CameraHubDiscoveryServiceCommand) async throws
}
