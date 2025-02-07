public protocol CameraHubClientPort: StateServiceClientPort
where
  State == CameraHubState,
  Event == CameraHubEvent,
  Command == CameraHubCommands
{
  var controllerDescriptor: CameraControllerDescriptor { get }
}
