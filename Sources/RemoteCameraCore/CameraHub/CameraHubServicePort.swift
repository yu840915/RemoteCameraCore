import Combine

public protocol CameraHubServicePort: StateServicePort
where
    State == CameraHubState,
    Event == CameraHubEvent,
    Command == CameraHubCommands
{
    var id: String { get }
}
