/// A symmetry of the image plane: a quarter turn, optionally with an axis flip.
///
/// That is the complete set of things that happen to a video buffer between the sensor and the
/// screen, so the general affine case is not worth carrying. Every coefficient is -1, 0 or 1,
/// so composing and inverting transforms is exact, where the trigonometric spelling leaves
/// rounding dust on every quarter turn.
///
/// Mapping a *point* is still ordinary floating point — the centring in
/// ``applyAboutUnitCentre(to:)`` rounds, to about 1e-16. Compare mapped points with a
/// tolerance; the corners and the centre happen to survive exactly, but nothing else is
/// promised.
///
/// Deliberately not a graphics type: this is domain geometry, and the module depends on no
/// frameworks. Bridge at the edge, where a `CGAffineTransform` or `CATransform3D` is needed.
public struct ImagePlaneTransform: Sendable, Equatable {
  /// Coefficients in the same order and convention as `CGAffineTransform`:
  /// `(x, y) -> (a * x + c * y, b * x + d * y)`.
  ///
  /// There is no translation component. The transform acts about the origin; callers working
  /// in corner-origin coordinates use ``applyAboutUnitCentre(to:)`` instead.
  public let a: Double
  public let b: Double
  public let c: Double
  public let d: Double

  public init(a: Double, b: Double, c: Double, d: Double) {
    self.a = a
    self.b = b
    self.c = c
    self.d = d
  }

  public static let identity = ImagePlaneTransform(a: 1, b: 0, c: 0, d: 1)

  /// A quarter turn, in the same direction as the equivalent `CGAffineTransform` rotation.
  public static let quarterTurnClockwise = ImagePlaneTransform(a: 0, b: 1, c: -1, d: 0)
  public static let quarterTurnCounterClockwise = ImagePlaneTransform(a: 0, b: -1, c: 1, d: 0)
  public static let halfTurn = ImagePlaneTransform(a: -1, b: 0, c: 0, d: -1)

  /// Flips left to right, leaving the vertical axis alone.
  public static let flippedHorizontally = ImagePlaneTransform(a: -1, b: 0, c: 0, d: 1)
  /// Flips top to bottom, leaving the horizontal axis alone.
  public static let flippedVertically = ImagePlaneTransform(a: 1, b: 0, c: 0, d: -1)

  /// `self` first, then `other` — the same order as `CGAffineTransform.concatenating(_:)`.
  public func concatenating(_ other: ImagePlaneTransform) -> ImagePlaneTransform {
    ImagePlaneTransform(
      a: a * other.a + b * other.c,
      b: a * other.b + b * other.d,
      c: c * other.a + d * other.c,
      d: c * other.b + d * other.d
    )
  }

  /// The transpose, which for these transforms is also the inverse — rotations and flips are
  /// orthogonal, so no division and no loss of precision.
  public var inverted: ImagePlaneTransform {
    ImagePlaneTransform(a: a, b: c, c: b, d: d)
  }

  public func apply(to point: Point) -> Point {
    Point(
      x: a * point.x + c * point.y,
      y: b * point.x + d * point.y
    )
  }

  /// Applies about the middle of the unit square, for normalised corner-origin coordinates.
  ///
  /// This is what keeps the transform independent of how large the view finder happens to be
  /// laid out: everything stays in unit space until the view multiplies by its own geometry.
  public func applyAboutUnitCentre(to point: Point) -> Point {
    let centred = Point(x: point.x - 0.5, y: point.y - 0.5)
    let mapped = apply(to: centred)
    return Point(x: mapped.x + 0.5, y: mapped.y + 0.5)
  }
}
