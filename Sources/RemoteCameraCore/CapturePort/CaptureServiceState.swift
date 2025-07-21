public struct CaptureServiceState: Sendable, Equatable {
  public var camera: CameraDescriptor?
  public var configuration = CameraConfiguration()
  public var capabilities = CameraCapabilities()
  public var availableConfigurationCommands = CaptureServiceCommand.ConfigurationCommand
    .FeatureTable()
  public init() {}

}
extension CaptureServiceState: CommandAvailabilityChecking {
  public func canPerform(
    _ command: CaptureServiceCommand.ConfigurationCommand
  ) -> Bool {
    switch command {
    case .setLivePhoto: availableConfigurationCommands.setLivePhoto
    case let .setTorchMode(arg):
      availableConfigurationCommands.setTorchMode
        && capabilities.torchModes.contains(
          arg
        )
    case let .setFlashMode(arg):
      availableConfigurationCommands.setFlashMode
        && capabilities.flashModes.contains(
          arg
        )
    case let .setZoomFactor(arg):
      availableConfigurationCommands.setZoomFactor
        && capabilities.zoomFactorRange?.contains(arg) ?? false
    case .smoothZoom: availableConfigurationCommands.smoothZoom
    case .setHDR: availableConfigurationCommands.setHDR
    case let .setFocusMode(arg):
      availableConfigurationCommands.setFocusMode && capabilities.focusModes.contains(arg)
    case let .setLensPosition(arg):
      availableConfigurationCommands.setLensPosition
        && capabilities.lensPositionRange?.contains(arg) ?? false
    case .setFocusPointOfInterest: availableConfigurationCommands.setFocusPointOfInterest
    case let .setExposureMode(arg):
      availableConfigurationCommands.setExposureMode && capabilities.exposureModes.contains(arg)
    case .setExposurePointOfInterest: availableConfigurationCommands.setExposurePointOfInterest
    case let .setExposureDuration(arg):
      availableConfigurationCommands.setExposureDuration
        && capabilities.exposureDurationRange?.contains(arg) ?? false
    case let .setISO(arf):
      availableConfigurationCommands.setISO
        && capabilities.isoRange?.contains(arf) ?? false
    case let .setWhiteBalanceMode(arg):
      availableConfigurationCommands.setWhiteBalanceMode
        && capabilities.whiteBalanceModes.contains(arg)
    case let .setTemperatureAndTint(arg):
      availableConfigurationCommands.setTemperatureAndTint
        && capabilities.whiteBalanceModes.contains(.locked)
        && capabilities.whiteBalanceTemperatureRange?.contains(arg.temperature) ?? false
        && capabilities.whiteBalanceTintRange?.contains(arg.tint) ?? false
    case let .setWhiteBalanceGains(arg):
      availableConfigurationCommands.setWhiteBalanceGains
        && capabilities.whiteBalanceRedGainsRange?.contains(arg.redGain) ?? false
        && capabilities.whiteBalanceGreenGainsRange?.contains(arg.greenGain) ?? false
        && capabilities.whiteBalanceBlueGainsRange?.contains(arg.blueGain) ?? false
    case .lockWhiteBalanceWithGrayWorld:
      availableConfigurationCommands.lockWhiteBalanceWithGrayWorld
        && capabilities.whiteBalanceModes.contains(.locked)
    }
  }
}

extension CaptureServiceState {
  public mutating func update(_ updates: [CaptureServiceStateUpdateMessage]) {
    for update in updates {
      self.update(update)
    }
  }

  public mutating func update(_ update: CaptureServiceStateUpdateMessage) {
    switch update {
    case let .cameraDescriptor(camera):
      self.camera = camera
    case let .configuration(configuration):
      self.configuration = configuration
    case let .capabilities(capabilities):
      self.capabilities = capabilities
    case let .availableConfigurationCommands(commands):
      availableConfigurationCommands = commands
    }
  }
}

public struct CameraConfiguration: Sendable, Equatable {
  public var isLivePhotoOn: Bool?

  public var torchMode: TorchMode?
  public var flashMode: FlashMode?
  public var zoomFactor: Double?
  public var isHDRon: Bool?
  public var lensAperture: Double?

  public var focusMode: FocusMode?
  public var lensPosition: Double?
  public var focusPointOfInterest: Point?

  public var exposureMode: ExposureMode?
  public var exposurePointOfInterest: Point?
  public var exposureDuration: Double?
  public var iso: Double?

  public var whiteBalanceMode: WhiteBalanceMode?
  public var temperatureAndTint: TemperatureAndTint?
  public var whiteBalanceGains: WhiteBalanceGains?

  public init() {}
}

public struct CameraCapabilities: Sendable, Equatable {
  public var torchModes: [TorchMode] = []
  public var flashModes: [FlashMode] = []
  public var zoomFactorRange: ValueRange<Double>?

  public var focusModes: [FocusMode] = []
  public var lensPositionRange: ValueRange<Double>?
  public var exposureModes: [ExposureMode] = []
  public var isoRange: ValueRange<Double>?
  public var exposureDurationRange: ValueRange<Double>?

  public var whiteBalanceModes: [WhiteBalanceMode] = []
  public var whiteBalanceTemperatureRange: ValueRange<Double>?
  public var whiteBalanceTintRange: ValueRange<Double>?
  public var whiteBalanceRedGainsRange: ValueRange<Double>?
  public var whiteBalanceGreenGainsRange: ValueRange<Double>?
  public var whiteBalanceBlueGainsRange: ValueRange<Double>?

  public init() {}
}

public enum CaptureServiceStateUpdateMessage: Sendable {
  case cameraDescriptor(CameraDescriptor)
  case configuration(CameraConfiguration)
  case capabilities(CameraCapabilities)
  case availableConfigurationCommands(CaptureServiceCommand.ConfigurationCommand.FeatureTable)
}

extension CaptureServiceState: CustomStringConvertible {
  public var description: String {
    "CaptureServiceState(camera: \(camera.description), configuration: \(configuration.description), capabilities: \(capabilities.description), availableConfigurationCommands: \(availableConfigurationCommands.description))"
  }
}

extension CameraConfiguration: CustomStringConvertible {
  public var description: String {
    var description = "CameraConfiguration("
    description += "isLivePhotoOn: \(isLivePhotoOn.description), "
    description += "torchMode: \(torchMode.description), "
    description += "flashMode: \(flashMode.description), "
    description += "zoomFactor: \(zoomFactor.description), "
    description += "isHDRon: \(isHDRon.description), "
    description += "lensAperture: \(lensAperture.description), "
    description += "focusMode: \(focusMode.description), "
    description += "lensPosition: \(lensPosition.description), "
    description += "focusPointOfInterest: \(focusPointOfInterest.description), "
    description += "exposureMode: \(exposureMode.description), "
    description += "exposurePointOfInterest: \(exposurePointOfInterest.description), "
    description += "exposureDuration: \(exposureDuration.description), "
    description += "iso: \(iso.description), "
    description += "whiteBalanceMode: \(whiteBalanceMode.description), "
    description += "temperatureAndTint: \(temperatureAndTint.description), "
    description += "whiteBalanceGains: \(whiteBalanceGains.description))"
    return description
  }
}

extension CameraCapabilities: CustomStringConvertible {
  public var description: String {
    var description = "CameraCapabilities("
    description += "torchModes: \(torchModes), "
    description += "flashModes: \(flashModes), "
    description += "zoomFactorRange: \(zoomFactorRange.description), "
    description += "focusModes: \(focusModes), "
    description += "lensPositionRange: \(lensPositionRange.description), "
    description += "exposureModes: \(exposureModes), "
    description += "isoRange: \(isoRange.description), "
    description += "exposureDurationRange: \(exposureDurationRange.description), "
    description += "whiteBalanceModes: \(whiteBalanceModes), "
    description += "temperatureRange: \(whiteBalanceTemperatureRange.description), "
    description += "tintRange: \(whiteBalanceTintRange.description), "
    description += "redGainsRange: \(whiteBalanceRedGainsRange.description), "
    description += "greenGainsRange: \(whiteBalanceGreenGainsRange.description), "
    description += "blueGainsRange: \(whiteBalanceBlueGainsRange.description))"
    return description
  }
}
extension CaptureServiceCommand.ConfigurationCommand
  .FeatureTable: CustomStringConvertible
{
  public var description: String {
    var description = "FeatureTable("
    description += "setLivePhoto: \(setLivePhoto), "
    description += "setTorchMode: \(setTorchMode), "
    description += "setFlashMode: \(setFlashMode), "
    description += "setZoomFactor: \(setZoomFactor), "
    description += "smoothZoom: \(smoothZoom), "
    description += "setHDR: \(setHDR), "
    description += "setFocusMode: \(setFocusMode), "
    description += "setLensPosition: \(setLensPosition), "
    description += "setFocusPointOfInterest: \(setFocusPointOfInterest), "
    description += "setExposureMode: \(setExposureMode), "
    description += "setExposurePointOfInterest: \(setExposurePointOfInterest), "
    description += "setExposureDuration: \(setExposureDuration), "
    description += "setISO: \(setISO), "
    description += "setWhiteBalanceMode: \(setWhiteBalanceMode), "
    description += "setTemperatureAndTint: \(setTemperatureAndTint), "
    description += "setWhiteBalanceGains: \(setWhiteBalanceGains), "
    description += "lockWhiteBalanceWithGrayWorld: \(lockWhiteBalanceWithGrayWorld))"
    return description
  }
}
extension CaptureServiceStateUpdateMessage: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .cameraDescriptor(camera):
      "CameraDescriptor: \(camera)"
    case let .configuration(configuration):
      "Configuration: \(configuration)"
    case let .capabilities(capabilities):
      "Capabilities: \(capabilities)"
    case let .availableConfigurationCommands(commands):
      "AvailableConfigurationCommands: \(commands)"
    }
  }
}

extension Optional: @retroactive CustomStringConvertible
where Wrapped: CustomStringConvertible {
  public var description: String {
    switch self {
    case .none: "nil"
    case let .some(value): value.description
    }
  }
}
