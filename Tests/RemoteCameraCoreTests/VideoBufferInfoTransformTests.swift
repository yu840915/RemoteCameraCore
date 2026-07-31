import RemoteCameraCore
import Testing

struct VideoBufferInfoTransformTests {
  private static let allBufferInfos: [VideoBufferInfo] = {
    let orientations: [ImageOrientation] = [
      .top, .topMirrored,
      .bottom, .bottomMirrored,
      .left, .leftMirrored,
      .right, .rightMirrored,
    ]
    let mirrorings: [VideoMirroring] = [.none, .horizontal, .vertical, .both]
    var infos: [VideoBufferInfo] = []
    for orientation in orientations {
      for mirroring in mirrorings {
        infos.append(
          VideoBufferInfo(
            dimensions: .init(width: 1920, height: 1080),
            orientation: orientation,
            mirroring: mirroring
          )
        )
      }
    }
    return infos
  }()

  private static let corners: [Point] = [
    .init(x: 0, y: 0),
    .init(x: 1, y: 0),
    .init(x: 0, y: 1),
    .init(x: 1, y: 1),
  ]

  private func info(
    _ orientation: ImageOrientation?,
    _ mirroring: VideoMirroring = .none
  ) -> VideoBufferInfo {
    VideoBufferInfo(
      dimensions: .init(width: 1920, height: 1080),
      orientation: orientation,
      mirroring: mirroring
    )
  }

  // MARK: - Round trip

  /// The whole reason this lives in one place: every orientation and mirroring combination has
  /// to survive a trip out to the view finder and back unchanged. A sign flip anywhere in the
  /// chain shows up here, rather than as a camera focusing on the wrong side of the frame.
  @Test(arguments: allBufferInfos)
  func roundTripsThroughDisplaySpace(_ sut: VideoBufferInfo) throws {
    let samplePoints: [Point] =
      Self.corners + [
        .init(x: 0.5, y: 0.5),
        .init(x: 0.25, y: 0.75),
        .init(x: 0.9, y: 0.1),
      ]
    for poi in samplePoints {
      let display = try #require(sut.displayPoint(for: poi))
      let restored = try #require(sut.pointOfInterest(for: display))

      #expect(
        restored.isApproximately(poi),
        "\(sut): \(poi) -> \(display) -> \(restored)"
      )
    }
  }

  // MARK: - Structure

  /// Every combination is a rigid motion of the square, so the four corners have to come out as
  /// the same four corners — no scaling, no shear, nothing pushed outside the unit square.
  @Test(arguments: allBufferInfos)
  func permutesTheCorners(_ sut: VideoBufferInfo) throws {
    let mapped = try Self.corners.map { try #require(sut.displayPoint(for: $0)) }

    for corner in Self.corners {
      #expect(
        mapped.contains(corner),
        "\(sut) never produced \(corner)"
      )
    }
  }

  /// Catches a missing or lopsided centring step: the middle of the frame is the one point
  /// every rotation and flip has to leave alone. Exact here — 0.5 survives the centring.
  @Test(arguments: allBufferInfos)
  func leavesTheCentreAlone(_ sut: VideoBufferInfo) throws {
    let centre = Point(x: 0.5, y: 0.5)
    let display = try #require(sut.displayPoint(for: centre))

    #expect(display == centre, "\(sut)")
  }

  // MARK: - Absolute placement

  @Test
  func leavesUprightBuffersAlone() throws {
    let poi = Point(x: 0.25, y: 0.75)
    let display = try #require(info(.top).displayPoint(for: poi))

    #expect(display == poi)
  }

  /// Pins the direction of rotation. `.left` turns the sensor's top-left corner into the
  /// display's top-right; if this flips, so does every point of interest.
  @Test
  func rotatesQuarterTurnsInTheDisplayDirection() throws {
    let topLeft = Point(x: 0, y: 0)
    let left = try #require(info(.left).displayPoint(for: topLeft))
    let right = try #require(info(.right).displayPoint(for: topLeft))
    let bottom = try #require(info(.bottom).displayPoint(for: topLeft))

    #expect(left == Point(x: 1, y: 0))
    #expect(right == Point(x: 0, y: 1))
    #expect(bottom == Point(x: 1, y: 1))
  }

  /// Mirroring is a display-only decision the buffer processor makes; the sensor knows nothing
  /// about it. Leave it out of the round trip and a mirrored preview sends points of interest
  /// to the wrong side of the frame.
  @Test
  func accountsForDisplayOnlyMirroring() throws {
    let horizontal = try #require(
      info(.top, .horizontal).displayPoint(for: .init(x: 0, y: 0.5))
    )
    let vertical = try #require(
      info(.top, .vertical).displayPoint(for: .init(x: 0.5, y: 0))
    )
    let both = try #require(info(.top, .both).displayPoint(for: .init(x: 0, y: 0)))

    #expect(horizontal == Point(x: 1, y: 0.5))
    #expect(vertical == Point(x: 0.5, y: 1))
    #expect(both == Point(x: 1, y: 1))
  }

  /// The mirror baked into the orientation and the one carried alongside it compose, rather
  /// than one quietly winning. Two horizontal flips cancel.
  @Test
  func composesBakedInAndExternalMirroring() throws {
    let poi = Point(x: 0.2, y: 0.6)
    let display = try #require(info(.topMirrored, .horizontal).displayPoint(for: poi))

    #expect(display == poi)
  }

  // MARK: - Edges

  /// An identity fallback would produce plausible-but-wrong points of interest. Better to have
  /// no answer at all, so the caller can hide the indicator.
  @Test
  func refusesToGuessWithoutAnOrientation() {
    let subject = info(nil, .horizontal)

    #expect(subject.displayPoint(for: .init(x: 0.5, y: 0.5)) == nil)
    #expect(subject.pointOfInterest(for: .init(x: 0.5, y: 0.5)) == nil)
  }

  /// A drag that runs off the edge of the view finder should pin to the border, not be rejected
  /// by the device as out of bounds.
  @Test
  func clampsPointsDraggedOffTheViewFinder() throws {
    let subject = info(.left)
    let low = try #require(subject.pointOfInterest(for: .init(x: -0.4, y: -1.2)))
    let high = try #require(subject.pointOfInterest(for: .init(x: 1.8, y: 3.0)))

    for value in [low.x, low.y, high.x, high.y] {
      #expect((0...1).contains(value))
    }
  }
}

extension Point {
  /// Mapping a point centres it on 0.5 and back, which rounds. The corners and the centre come
  /// out exact, but nothing else does, so comparisons carry a tolerance far below anything a
  /// camera could act on.
  fileprivate func isApproximately(_ other: Point, tolerance: Double = 1e-12) -> Bool {
    abs(x - other.x) < tolerance && abs(y - other.y) < tolerance
  }
}
