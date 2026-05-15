public struct CaptureTaskInfo: Sendable, Equatable {
  public let id: String
  public let startAt: Timestamp

  public init(id: String, startAt: Timestamp) {
    self.id = id
    self.startAt = startAt
  }
}
