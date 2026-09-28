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
    frameDuration.frameRate
  }
  public let frameDuration: RationalDuration

  public init(frameRate: DurationScale) {
    if frameRate > 0 {
      self.frameDuration = RationalDuration(frameRate: frameRate)
    } else {
      self.frameDuration = .zero
    }
  }

  public init(frameDuration: RationalDuration) {
    precondition(frameDuration > .zero, "Frame duration must be positive")
    self.frameDuration = frameDuration
  }
}

public struct TimelapseRecordingSettings: Sendable, Equatable {
  public let interval: Duration
  public var frameDuration: RationalDuration {
    videoRecordingSettings.frameDuration
  }
  public var frameRate: Double {
    videoRecordingSettings.frameRate
  }
  private let videoRecordingSettings: VideoRecordingSettings

  public init(interval: Duration, frameRate: DurationScale) {
    self.init(
      interval: interval,
      videoRecordingSettings: VideoRecordingSettings(frameRate: frameRate),
    )
  }

  public init(interval: Duration, frameDuration: RationalDuration) {
    self.init(
      interval: interval,
      videoRecordingSettings: VideoRecordingSettings(frameDuration: frameDuration),
    )
  }

  init(interval: Duration, videoRecordingSettings: VideoRecordingSettings) {
    self.videoRecordingSettings = videoRecordingSettings
    self.interval = max(interval, videoRecordingSettings.frameDuration.duration)
  }

  public func estimateTimeLapseDuration(from recordingDuration: Duration) -> RationalDuration {
    guard recordingDuration > .zero && interval > .zero else {
      return .zero
    }
    let frameCount = Int64((recordingDuration / interval).rounded(.down)) + 1
    return RationalDuration(
      value: frameDuration.value * frameCount,
      scale: frameDuration.scale
    )
  }

}
