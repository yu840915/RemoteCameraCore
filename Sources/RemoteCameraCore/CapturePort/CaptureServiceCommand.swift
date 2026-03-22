public enum CaptureServiceCommand: Sendable {
  case start
  case stop
  case capturePhoto(TaskSchedule)
  case cancelCapture(taskId: String)
  case startVideoRecording(VideoRecordingArguments)
  case startTimelapseRecording(TimelapseRecordingArguments)
  case stopRecording(taskId: String)
  case switchCamera(cameraID: String)
  case configure(commands: [ConfigurationCommand])
  case setMode(mode: CaptureMode)

  public struct FeatureTable: Sendable, Equatable {
    public var capturePhoto = false
    public var cancelCapture = false
    public var startVideoRecording = false
    public var startTimelapseRecording = false
    public var stopRecording = false
    public var switchCamera = false
    public var configure = false
    public var setMode = false

    public init() {}
  }
}

public enum TaskSchedule: Sendable {
  case now
  case delayed(Duration)
  case at(Timestamp)
}

extension CaptureServiceCommand {
  public struct VideoRecordingArguments: Sendable {
    public let schedule: TaskSchedule

    public init(schedule: TaskSchedule = .now) {
      self.schedule = schedule
    }
  }
  public struct TimelapseRecordingArguments: Sendable {
    public let schedule: TaskSchedule
    public let interval: Duration

    public init(interval: Duration, schedule: TaskSchedule = .now) {
      self.interval = interval
      self.schedule = schedule
    }
  }
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

    public struct FeatureTable: Sendable, Equatable {
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
}
