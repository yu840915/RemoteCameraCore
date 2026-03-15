public enum ImageOrientation: UInt8, Sendable {
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

  public func mirrored() -> ImageOrientation {
    switch self {
    case .top: .topMirrored
    case .topMirrored: .top
    case .bottom: .bottomMirrored
    case .bottomMirrored: .bottom
    case .left: .leftMirrored
    case .leftMirrored: .left
    case .right: .rightMirrored
    case .rightMirrored: .right
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

  public func displayDimensions(for dimensions: (width: Int, height: Int)) -> (
    width: Int, height: Int
  ) {
    switch self {
    case .top, .topMirrored, .bottom, .bottomMirrored:
      dimensions
    case .left, .leftMirrored, .right, .rightMirrored:
      (width: dimensions.height, height: dimensions.width)
    }
  }

  public func rotateClockwise() -> ImageOrientation {
    switch self {
    case .top: .right
    case .right: .bottom
    case .bottom: .left
    case .left: .top
    case .topMirrored: .rightMirrored
    case .rightMirrored: .bottomMirrored
    case .bottomMirrored: .leftMirrored
    case .leftMirrored: .topMirrored
    }
  }

  public func rotateCounterClockwise() -> ImageOrientation {
    switch self {
    case .top: .left
    case .right: .top
    case .bottom: .right
    case .left: .bottom
    case .topMirrored: .leftMirrored
    case .rightMirrored: .topMirrored
    case .bottomMirrored: .rightMirrored
    case .leftMirrored: .bottomMirrored
    }
  }

  public func rotate180() -> ImageOrientation {
    switch self {
    case .top: .bottom
    case .right: .left
    case .bottom: .top
    case .left: .right
    case .topMirrored: .bottomMirrored
    case .rightMirrored: .leftMirrored
    case .bottomMirrored: .topMirrored
    case .leftMirrored: .rightMirrored
    }
  }
}
