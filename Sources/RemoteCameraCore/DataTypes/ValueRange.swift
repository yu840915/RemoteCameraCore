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

extension ValueRange where Bound: SignedInteger {
  public func proportionalValue(for value: Bound) -> Double {
    let value = clamp(value)
    return Double(value - min) / Double(max - min)
  }
}

extension ValueRange where Bound == Double {
  public func proportionalValue(for value: Bound) -> Double {
    let value = clamp(value)
    return (value - min) / (max - min)
  }
}

extension ValueRange {
  public enum ValidationError: Int, Error {
    case outOfRange = 1
  }
}

extension ValueRange: Equatable {
  public static func == (lhs: ValueRange, rhs: ValueRange) -> Bool {
    lhs.min == rhs.min && lhs.max == rhs.max
  }
}

extension ValueRange: CustomStringConvertible where Bound == Double {
  public var description: String {
    "[\(min), \(max)]"
  }
}

extension ValueRange where Bound: SignedInteger {
  public var description: String {
    "[\(min), \(max)]"
  }
}
