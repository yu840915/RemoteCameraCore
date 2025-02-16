public protocol CameraHubClientPort: StateServiceClientPort
where
  State == CameraHubState,
  Event == CameraHubRemoteEvent,
  Command == CameraHubCommand
{
  var controllerDescriptor: CameraControllerDescriptor { get }
}
