public struct ValueRange<Bound: Comparable & Sendable>: Sendable {
  public let min: Bound
  public let max: Bound
  public init(singular value: Bound) {
    self.min = value
    self.max = value
  }

  public init(min: Bound, max: Bound) {
    self.min = min
    self.max = max
  }

  public init(checkedMin min: Bound, max: Bound) throws {
    guard min <= max else {
      throw ValidationError.outOfRange
    }
    self.min = min
    self.max = max
  }

  public func contains(_ value: Bound) -> Bool {
    min <= value && value <= max
  }

  public func clamp(_ value: Bound) -> Bound {
    Swift.min(Swift.max(value, min), max)
  }
}

extension ValueRange {
  public enum ValidationError: Error {
    case outOfRange
  }
}
