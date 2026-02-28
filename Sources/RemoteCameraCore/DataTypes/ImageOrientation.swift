public enum ImageOrientation: Int, Sendable {
  case top = 1
  case topMirrored = 2
  case bottom = 3
  case bottomMirrored = 4
  case leftMirrored = 5
  case right = 6
  case rightMirrored = 7
  case left = 8

  public var isMirrored: Bool {
    switch self {
    case .top, .bottom, .left, .right: false
    case .topMirrored, .bottomMirrored, .leftMirrored, .rightMirrored: true
    }
  }

  ///Note: in radians
  public var rotation: Double {
    switch self {
    case .top, .topMirrored: 0
    case .right, .rightMirrored: 3 * .pi / 2
    case .bottom, .bottomMirrored: .pi
    case .left, .leftMirrored: .pi / 2
    }
  }

  public func displayDimensions(for dimensions: (width: Int, height: Int)) -> (width: Int, height: Int) {
    switch self {
    case .top, .topMirrored, .bottom, .bottomMirrored:
      dimensions
    case .left, .leftMirrored, .right, .rightMirrored:
      (width: dimensions.height, height: dimensions.width)
    }
  }
}
