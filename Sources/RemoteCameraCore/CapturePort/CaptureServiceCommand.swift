public enum CaptureServiceCommand: Sendable {
  case start
  case stop
  case takePicture
  case swithCamera(cameraID: String)
  case configure(commands: [ConfigurationCommand])
}

extension CaptureServiceCommand {
  public enum ConfigurationCommand: Sendable {
    case setLivePhoto(on: Bool)

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
      public var setLivePhoto = false
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
        case .setLivePhoto: return setLivePhoto
        case .setTorchMode: return setTorchMode
        case .setFlashMode: return setFlashMode
        case .setZoomFactor: return setZoomFactor
        case .smoothZoom: return smoothZoom
        case .setHDR: return setHDR
        case .setFocusMode: return setFocusMode
        case .setLensPosition: return setLensPosition
        case .setFocusPointOfInterest: return setFocusPointOfInterest
        case .setExposureMode: return setExposureMode
        case .setExposurePointOfInterest: return setExposurePointOfInterest
        case .setExposureDuration: return setExposureDuration
        case .setISO: return setISO
        case .setWhiteBalanceMode: return setWhiteBalanceMode
        case .setTemperatureAndTint: return setTemperatureAndTint
        case .setWhiteBalanceGains: return setWhiteBalanceGains
        case .lockWhiteBalanceWithGrayWorld: return lockWhiteBalanceWithGrayWorld
        }
      }

      public init() {}
    }
  }
}

extension CaptureServiceCommand.ConfigurationCommand.FeatureTable {
  public mutating func enableAll() {
    setLivePhoto = true
    setTorchMode = true
    setFlashMode = true
    setZoomFactor = true
    smoothZoom = true
    setHDR = true
    setFocusMode = true
    setLensPosition = true
    setFocusPointOfInterest = true
    setExposureMode = true
    setExposurePointOfInterest = true
    setExposureDuration = true
    setISO = true
    setWhiteBalanceMode = true
    setTemperatureAndTint = true
    setWhiteBalanceGains = true
    lockWhiteBalanceWithGrayWorld = true
  }

  public mutating func disableFeature(on capabilities: CameraCapabilities) {
    if capabilities.focusModes.isEmpty {
      setFocusMode = false
    }
    if capabilities.torchModes.isEmpty {
      setTorchMode = false
    }
    if capabilities.flashModes.isEmpty {
      setFlashMode = false
    }
    if capabilities.zoomFactorRange == nil {
      setZoomFactor = false
      smoothZoom = false
    }
    if capabilities.exposureModes.isEmpty {
      setExposureMode = false
    }
    if capabilities.lensPositionRange == nil {
      setLensPosition = false
    }
    if capabilities.exposureDurationRange == nil {
      setExposureDuration = false
    }
    if capabilities.isoRange == nil {
      setISO = false
    }
    if capabilities.whiteBalanceModes.isEmpty {
      setWhiteBalanceMode = false
      lockWhiteBalanceWithGrayWorld = false
    } else if !capabilities.whiteBalanceModes.contains(.locked) {
      lockWhiteBalanceWithGrayWorld = false
    }

    if capabilities.whiteBalanceTemperatureRange == nil
      && capabilities.whiteBalanceTintRange == nil
    {
      setTemperatureAndTint = false
    }
    if capabilities.whiteBalanceRedGainsRange == nil
      && capabilities.whiteBalanceGreenGainsRange == nil
      && capabilities.whiteBalanceBlueGainsRange == nil
    {
      setWhiteBalanceGains = false
    }
  }
}
