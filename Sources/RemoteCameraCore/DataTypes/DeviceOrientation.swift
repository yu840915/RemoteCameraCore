public struct DeviceOrientation: Sendable, Equatable {
  // in radians, 0 is east, counterclockwise, e.g. west is pi
  public var heading: Double
  /// device tilt, in radians, 0 facing forward, pi/2 facing up, -pi/2 facing down, e.g. horizon is 0, sky is pi/2, ground is -pi/2
  /// -pi/2 to pi/2
  public var pitch: Double

  public init(
    heading: Double = 0,
    pitch: Double = 0,
  ) {
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
    to other: DeviceOrientation,
    headingThreshold: Double = .pi / 2,
    pitchThreshold: Double = 2 * .pi / 3,
  ) -> Bool {
    let pitchAngle = min(abs(pitch - other.pitch), abs(other.pitch - pitch))
    if pitchAngle > pitchThreshold {
      return true
    }
    let headingAngle = min(abs(heading - other.heading), abs(other.heading - heading))
    return headingAngle > headingThreshold
  }

  public var opposite: DeviceOrientation {
    DeviceOrientation(heading: heading + .pi, pitch: -pitch)
  }
}
