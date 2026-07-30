import RemoteCameraCore
import Testing

struct ImagePlaneTransformTests {
  private static let all: [ImagePlaneTransform] = [
    .identity,
    .quarterTurnClockwise,
    .quarterTurnCounterClockwise,
    .halfTurn,
    .flippedHorizontally,
    .flippedVertically,
  ]

  /// `inverted` returns the transpose. That is only the inverse because these transforms are
  /// orthogonal, so the assumption is worth holding down.
  @Test
  func invertsByTransposing() {
    for transform in Self.all {
      #expect(transform.concatenating(transform.inverted) == .identity)
      #expect(transform.inverted.concatenating(transform) == .identity)
    }
  }

  @Test
  func composesQuarterTurns() {
    #expect(
      ImagePlaneTransform.quarterTurnClockwise
        .concatenating(.quarterTurnClockwise) == .halfTurn
    )
    #expect(
      ImagePlaneTransform.quarterTurnClockwise
        .concatenating(.quarterTurnCounterClockwise) == .identity
    )
    #expect(ImagePlaneTransform.halfTurn.concatenating(.halfTurn) == .identity)
  }

  /// Rotation and flipping do not commute — mirroring before a quarter turn lands somewhere
  /// else than mirroring after it. This is exactly where the two existing spellings of the
  /// orientation table in `AVCameraAdapter` disagree.
  @Test
  func rotationAndFlippingDoNotCommute() {
    let flipThenTurn = ImagePlaneTransform.flippedHorizontally
      .concatenating(.quarterTurnClockwise)
    let turnThenFlip = ImagePlaneTransform.quarterTurnClockwise
      .concatenating(.flippedHorizontally)
    #expect(flipThenTurn != turnThenFlip)
    #expect(flipThenTurn == turnThenFlip.concatenating(.halfTurn))
  }

  @Test
  func flipsAreTheirOwnInverse() {
    #expect(
      ImagePlaneTransform.flippedHorizontally
        .concatenating(.flippedHorizontally) == .identity
    )
    #expect(
      ImagePlaneTransform.flippedVertically
        .concatenating(.flippedVertically) == .identity
    )
    #expect(
      ImagePlaneTransform.flippedHorizontally
        .concatenating(.flippedVertically) == .halfTurn
    )
  }

  /// Applied about the origin, a quarter turn takes the +x axis onto the +y axis — the same
  /// direction `CGAffineTransform(rotationAngle:)` turns, so the bridge needs no correction.
  @Test
  func rotatesAboutTheOrigin() {
    let turned = ImagePlaneTransform.quarterTurnClockwise.apply(to: .init(x: 1, y: 0))
    #expect(turned == Point(x: 0, y: 1))
  }

  @Test
  func rotatesAboutTheCentreOfTheUnitSquare() {
    let transform = ImagePlaneTransform.quarterTurnClockwise
    #expect(transform.applyAboutUnitCentre(to: .init(x: 0.5, y: 0.5)) == Point(x: 0.5, y: 0.5))
    #expect(transform.applyAboutUnitCentre(to: .init(x: 0, y: 0)) == Point(x: 1, y: 0))
    #expect(transform.applyAboutUnitCentre(to: .init(x: 1, y: 0)) == Point(x: 1, y: 1))
  }
}
