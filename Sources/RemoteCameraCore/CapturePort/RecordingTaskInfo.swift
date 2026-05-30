public struct RecordingTaskInfo: Sendable, Equatable {
  public let id: String
  public let startAt: Timestamp
  public let endAt: Timestamp?
  public let type: TaskType

  public init(
    id: String,
    startAt: Timestamp,
    endAt: Timestamp? = nil,
    type: TaskType
  ) {
    self.id = id
    self.startAt = startAt
    self.endAt = endAt
    self.type = type
  }
}

extension RecordingTaskInfo {
  public enum TaskType: Sendable, Equatable {
    case video(VideoRecordingSettings)
    case timelapse(TimelapseRecordingSettings)
  }
}

public struct VideoRecordingSettings: Sendable, Equatable {
  public var frameRate: Double {
    if frameDuration > .zero {
      return 1.0 / frameDuration.doubleValue
    } else {
      return .zero
    }
  }
  public let frameDuration: Duration

  public init(frameRate: Double) {
    if frameRate > 0 {
      self.frameDuration = Duration(1.0 / frameRate)
    } else {
      self.frameDuration = .zero
    }
  }

  public init(frameDuration: Duration) {
    precondition(frameDuration > .zero, "Frame duration must be positive")
    self.frameDuration = frameDuration
  }
}

public struct TimelapseRecordingSettings: Sendable, Equatable {
  public let interval: Duration
  public var frameDuration: Duration {
    videoRecordingSettings.frameDuration
  }
  public var frameRate: Double {
    videoRecordingSettings.frameRate
  }
  private let videoRecordingSettings: VideoRecordingSettings

  public init(interval: Duration, frameRate: Double) {
    self.init(
      interval: interval,
      videoRecordingSettings: VideoRecordingSettings(frameRate: frameRate),
    )
  }

  public init(interval: Duration, frameDuration: Duration) {
    self.init(
      interval: interval,
      videoRecordingSettings: VideoRecordingSettings(frameDuration: frameDuration),
    )
  }

  init(interval: Duration, videoRecordingSettings: VideoRecordingSettings) {
    self.videoRecordingSettings = videoRecordingSettings
    self.interval = max(interval, videoRecordingSettings.frameDuration)
  }

  public func estimateTimeLapseDuration(from recordingDuration: Duration) -> Duration {
    guard recordingDuration > .zero && interval > .zero else {
      return .zero
    }
    let frameCount = (recordingDuration / interval).rounded(.down)
    return frameDuration * Int(frameCount + 1)
  }

}
