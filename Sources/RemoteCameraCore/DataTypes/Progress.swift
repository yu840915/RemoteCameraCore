public struct Progress: Sendable, Equatable {
  public static func + (lhs: Progress, rhs: Progress) -> Progress {
    Progress(
      finished: lhs.finished + rhs.finished,
      total: lhs.total + rhs.total
    )
  }

  public var finished: UInt {
    didSet {
      if finished > total {
        finished = total
      }
    }
  }
  public let total: UInt

  public init(finished: UInt, total: UInt) {
    self.finished = min(finished, total)
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
