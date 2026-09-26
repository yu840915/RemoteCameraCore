public struct ImageDimensions: Equatable, Sendable {
  public var width: Int
  public var height: Int

  public var isPortrait: Bool {
    height > width
  }

  public var isLandscape: Bool {
    width > height
  }

  public var isSquare: Bool {
    width == height
  }

  public init(width: Int, height: Int) {
    precondition(width > 0 && height > 0)
    self.width = width
    self.height = height
  }

  public func transposed() -> ImageDimensions {
    ImageDimensions(width: height, height: width)
  }
}
