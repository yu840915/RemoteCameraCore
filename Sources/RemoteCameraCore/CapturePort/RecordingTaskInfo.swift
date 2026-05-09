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
    case timeElapse(TimeElapseRecordingSettings)
  }
}

public struct VideoRecordingSettings: Sendable, Equatable {
  public let frameRate: Double

  public init(frameRate: Double) {
    self.frameRate = frameRate
  }
}

public struct TimeElapseRecordingSettings: Sendable, Equatable {
  public let interval: Duration
  public let frameRate: Double

  public init(interval: Duration, frameRate: Double) {
    self.interval = interval
    self.frameRate = frameRate
  }
}
