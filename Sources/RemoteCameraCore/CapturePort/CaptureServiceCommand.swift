public enum CaptureServiceCommand: Sendable {
  case start
  case stop
  case takePicture
  case swithCamera(cameraID: String)
  case configure(commands: [ConfigurationCommand])
}

extension CaptureServiceCommand {
  public enum ConfigurationCommand: Sendable {
    case setTorchMode(mode: TorchMode)
    case setFlashMode(mode: FlashMode)
    case setZoomFactor(factor: Double)
    case smoothZoom(rate: Double)

    case setHDR(on: Bool)

    case setFocusMode(mode: FocusMode)
    case setLensPosition(position: Double)
    case setFocusPointOfInterest(point: Point)

    case setExposureMode(mode: ExposureMode)
    case setExposurePointOfInterest(point: Point)
    case setExposureDuration(seconds: Double)
    case setISO(iso: Double)

    case setWhiteBalanceMode(mode: WhiteBalanceMode)
    case setTemperatureAndTint(value: TemperatureAndTint)
    case setWhiteBalanceGains(gains: WhiteBalanceGains)
    case lockWhiteBalanceWithGrayWorld

    public struct FeatureTable: CommandAvailabilityChecking {
      var setTorchMode = false
      var setFlashMode = false
      var setZoomFactor = false
      var smoothZoom = false
      var setHDR = false
      var setFocusMode = false
      var setLensPosition = false
      var setFocusPointOfInterest = false
      var setExposureMode = false
      var setExposurePointOfInterest = false
      var setExposureDuration = false
      var setISO = false
      var setWhiteBalanceMode = false
      var setTemperatureAndTint = false
      var setWhiteBalanceGains = false
      var lockWhiteBalanceWithGrayWorld = false

      func canPerform(_ command: ConfigurationCommand) -> Bool {
        switch command {
        case .setTorchMode(_): return setTorchMode
        case .setFlashMode(_): return setFlashMode
        case .setZoomFactor(_): return setZoomFactor
        case .smoothZoom(_): return smoothZoom
        case .setHDR(_): return setHDR
        case .setFocusMode(_): return setFocusMode
        case .setLensPosition(_): return setLensPosition
        case .setFocusPointOfInterest(_): return setFocusPointOfInterest
        case .setExposureMode(_): return setExposureMode
        case .setExposurePointOfInterest(_): return setExposurePointOfInterest
        case .setExposureDuration(_): return setExposureDuration
        case .setISO(_): return setISO
        case .setWhiteBalanceMode(_): return setWhiteBalanceMode
        case .setTemperatureAndTint(_): return setTemperatureAndTint
        case .setWhiteBalanceGains(_): return setWhiteBalanceGains
        case .lockWhiteBalanceWithGrayWorld: return lockWhiteBalanceWithGrayWorld
        }
      }
    }
  }

}
