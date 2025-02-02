public enum CameraHubEvent: Sendable {
  case capture(capture: any CaptureServicePort)
}
