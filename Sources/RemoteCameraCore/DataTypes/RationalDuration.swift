public typealias DurationScale = Int32

public struct RationalDuration: Sendable {
  public let value: Int64
  public let scale: DurationScale

  public var isValid: Bool {
    scale > 0
  }

  public var seconds: Double {
    guard isValid else {
      return 0
    }
    return Double(value) / Double(scale)
  }

  public var frameRate: Double {
    guard isValid, value != 0 else {
      return 0
    }
    return Double(scale) / Double(value)
  }

  public init(value: Int64, scale: DurationScale) {
    if scale < 0, value != Int64.min, scale != DurationScale.min {
      self.value = -value
      self.scale = -scale
    } else {
      self.value = value
      self.scale = scale
    }
  }

  public init(frameRate: DurationScale) {
    self.init(value: 1, scale: frameRate)
  }

  public static let zero = RationalDuration(value: 0, scale: 1)
}

extension RationalDuration: Hashable, Comparable {
  public static func == (lhs: RationalDuration, rhs: RationalDuration) -> Bool {
    guard lhs.isValid, rhs.isValid else {
      return lhs.isValid == rhs.isValid
    }
    let left = lhs.crossMultiplied(with: rhs)
    let right = rhs.crossMultiplied(with: lhs)
    return left.high == right.high && left.low == right.low
  }

  public static func < (lhs: RationalDuration, rhs: RationalDuration) -> Bool {
    guard lhs.isValid, rhs.isValid else {
      return !lhs.isValid && rhs.isValid
    }
    let left = lhs.crossMultiplied(with: rhs)
    let right = rhs.crossMultiplied(with: lhs)
    return left.high == right.high ? left.low < right.low : left.high < right.high
  }

  public func hash(into hasher: inout Hasher) {
    guard isValid else {
      hasher.combine(0 as Int64)
      hasher.combine(0 as Int64)
      return
    }
    let divisor = Self.greatestCommonDivisor(value.magnitude, UInt64(scale))
    hasher.combine(value / Int64(divisor))
    hasher.combine(Int64(scale) / Int64(divisor))
  }

  /// A 128-bit product, since `Int128` needs iOS 18 and this package targets 17.
  /// Two's complement makes (signed high, unsigned low) compare lexicographically.
  private func crossMultiplied(with other: RationalDuration) -> (high: Int64, low: UInt64) {
    value.multipliedFullWidth(by: Int64(other.scale))
  }

  private static func greatestCommonDivisor(_ a: UInt64, _ b: UInt64) -> UInt64 {
    var a = a
    var b = b
    while b != 0 {
      (a, b) = (b, a % b)
    }
    return a == 0 ? 1 : a
  }
}

extension RationalDuration: CustomStringConvertible {
  public var description: String {
    guard isValid else {
      return "RationalDuration(invalid: \(value)/\(scale))"
    }
    return "RationalDuration(\(value)/\(scale), \(frameRate) fps)"
  }
}

extension RationalDuration {
  /// Bridges to `Duration` for callers that measure in wall-clock time. The
  /// fraction is kept to the attosecond, which still rounds a rational such as
  /// 1/30, so do not compare the result against another duration for equality.
  public var duration: Duration {
    guard isValid else {
      return .zero
    }
    let scale = Int64(scale)
    let fraction = (value % scale).multipliedFullWidth(by: 1_000_000_000_000_000_000)
    return Duration(
      secondsComponent: value / scale,
      attosecondsComponent: scale.dividingFullWidth(fraction).quotient
    )
  }
}
