public struct TaskProgress: Sendable, Equatable {
  public static func + (lhs: TaskProgress, rhs: TaskProgress) -> TaskProgress {
    TaskProgress(
      finished: lhs.finished + rhs.finished,
      total: lhs.total + rhs.total
    )
  }
  private var finishedVal: UInt
  public var finished: UInt {
    get { finishedVal }
    set {
      finishedVal = min(newValue, total)
    }
  }
  public let total: UInt

  public init(finished: UInt, total: UInt) {
    self.finishedVal = min(finished, total)
    self.total = total
  }

  public var fractionCompleted: Double {
    guard total > 0 else { return 0 }
    return Double(finished) / Double(total)
  }

  public var isComplete: Bool {
    finished >= total
  }

  public var hasStarted: Bool {
    finished > 0
  }
}
