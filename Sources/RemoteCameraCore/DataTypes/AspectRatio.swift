public struct AspectRatio: Sendable {
  public let width: Int
  public let height: Int

  public var isValid: Bool {
    width > 0 && height > 0
  }

  public var ratio: Double {
    guard isValid else {
      return 0
    }
    return Double(width) / Double(height)
  }

  public init(width: Int, height: Int) {
    self.width = width
    self.height = height
  }

  public static let standard = AspectRatio(width: 4, height: 3)
  public static let widescreen = AspectRatio(width: 16, height: 9)
  public static let square = AspectRatio(width: 1, height: 1)
}

extension AspectRatio: Hashable, Comparable {
  public static func == (lhs: AspectRatio, rhs: AspectRatio) -> Bool {
    guard lhs.isValid, rhs.isValid else {
      return lhs.isValid == rhs.isValid
    }
    return lhs.width * rhs.height == rhs.width * lhs.height
  }

  /// Narrower sorts before wider.
  public static func < (lhs: AspectRatio, rhs: AspectRatio) -> Bool {
    guard lhs.isValid, rhs.isValid else {
      return !lhs.isValid && rhs.isValid
    }
    return lhs.width * rhs.height < rhs.width * lhs.height
  }

  public func hash(into hasher: inout Hasher) {
    guard isValid else {
      hasher.combine(0)
      hasher.combine(0)
      return
    }
    let divisor = Self.greatestCommonDivisor(width, height)
    hasher.combine(width / divisor)
    hasher.combine(height / divisor)
  }

  private static func greatestCommonDivisor(_ a: Int, _ b: Int) -> Int {
    var a = a
    var b = b
    while b != 0 {
      (a, b) = (b, a % b)
    }
    return a == 0 ? 1 : a
  }
}

extension AspectRatio: CustomStringConvertible {
  public var description: String {
    guard isValid else {
      return "AspectRatio(invalid: \(width):\(height))"
    }
    let divisor = Self.greatestCommonDivisor(width, height)
    return "AspectRatio(\(width / divisor):\(height / divisor))"
  }
}

extension ImageDimensions {
  public var aspectRatio: AspectRatio {
    AspectRatio(width: width, height: height)
  }
}
