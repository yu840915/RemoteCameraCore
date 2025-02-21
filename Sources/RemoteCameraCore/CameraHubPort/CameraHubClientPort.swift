public protocol CameraHubClientPort: StateServiceClientPort
where
  State == CameraHubState,
  Event == CameraHubEvent,
  Command == CameraHubCommand
{
  var controllerDescriptor: CameraControllerDescriptor { get }
}
