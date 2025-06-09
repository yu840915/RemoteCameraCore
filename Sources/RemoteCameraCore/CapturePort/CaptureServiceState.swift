public struct CaptureServiceState: Sendable, Equatable {
  public var camera: CameraDescriptor?
  public var configuration = CameraConfiguration()
  public var capabilities = CameraCapabilities()
  public var availableConfigurationCommands = CaptureServiceCommand.ConfigurationCommand
    .FeatureTable()
  public init() {}
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
