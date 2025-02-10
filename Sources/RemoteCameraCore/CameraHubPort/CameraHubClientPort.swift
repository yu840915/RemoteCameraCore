public protocol CameraHubClientPort: StateServiceClientPort
where
  State == CameraHubState,
  Event == CameraHubRemoteEvent,
  Command == CameraHubCommands
{
  var controllerDescriptor: CameraControllerDescriptor { get }
}
