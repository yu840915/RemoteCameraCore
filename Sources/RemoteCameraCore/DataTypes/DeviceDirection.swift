public struct DeviceDirection: Sendable, Equatable {
  // in radians, 0 is east, counterclockwise, e.g. west is pi
  public let heading: Double
  /// device tilt, in radians, 0 facing forward, pi/2 facing up, -pi/2 facing down, e.g. horizon is 0, sky is pi/2, ground is -pi/2
  /// -pi/2 to pi/2
  public let pitch: Double
  private let type: Type

  public static let virtualForward = DeviceDirection(type: .virtualForward)
  public static let virtualBackward = DeviceDirection(type: .virtualBackward)

  public init(
    heading: Double = 0,
    pitch: Double = 0,
  ) {
    self.init(heading: heading, pitch: pitch, type: .physical)
  }

  init(
    heading: Double = 0,
    pitch: Double = 0,
    type: Type
  ) {
    self.type = type
    let yaw = heading.truncatingRemainder(dividingBy: 2 * .pi)
    self.heading = yaw >= 0 ? yaw : yaw + 2 * .pi
    var p = pitch.truncatingRemainder(dividingBy: 2 * .pi)
    p = p >= 0 ? p : p + 2 * .pi
    if p >= 3 * .pi / 2 {
      self.pitch = p - 2 * .pi
    } else if p > .pi / 2 {
      self.pitch = -p + .pi
    } else {
      self.pitch = p
    }
  }

  public init(
    compassHeading: Double,
    pitch: Double,
  ) {
    let heading = (90 - compassHeading).truncatingRemainder(dividingBy: 360)
    self.init(heading: heading * .pi / 180, pitch: pitch)
  }

  public func isArroximatelyOpposite(
    to other: DeviceDirection,
    headingThreshold: Double = .pi / 2,
    pitchThreshold: Double = 2 * .pi / 3,
  ) -> Bool {
    guard type == .physical && other.type == .physical else {
      if type == .physical || other.type == .physical {
        return false
      }
      return type != other.type
    }
    let pitchAngle = min(abs(pitch - other.pitch), abs(other.pitch - pitch))
    if pitchAngle > pitchThreshold {
      return true
    }
    let headingAngle = min(abs(heading - other.heading), 2 * .pi - abs(heading - other.heading))
    return headingAngle > headingThreshold
  }

  public var opposite: DeviceDirection {
    DeviceDirection(heading: heading + .pi, pitch: -pitch)
  }
}

extension DeviceDirection {
  enum `Type`: Sendable {
    case physical
    case virtualForward
    case virtualBackward
  }
}
