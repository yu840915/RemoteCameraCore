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
      public var setTorchMode = false
      public var setFlashMode = false
      public var setZoomFactor = false
      public var smoothZoom = false
      public var setHDR = false
      public var setFocusMode = false
      public var setLensPosition = false
      public var setFocusPointOfInterest = false
      public var setExposureMode = false
      public var setExposurePointOfInterest = false
      public var setExposureDuration = false
      public var setISO = false
      public var setWhiteBalanceMode = false
      public var setTemperatureAndTint = false
      public var setWhiteBalanceGains = false
      public var lockWhiteBalanceWithGrayWorld = false

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

      public init() {}
    }
  }

}
