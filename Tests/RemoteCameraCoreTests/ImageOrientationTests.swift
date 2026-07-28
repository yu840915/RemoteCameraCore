import RemoteCameraCore
import Testing

struct ImageOrientationTests {
  @Test
  func convertToDisplayDimensions() async throws {
    #expect(
      ImageOrientation.top.displayDimensions(for: (width: 100, height: 200))
        == (width: 100, height: 200),
    )
    #expect(
      ImageOrientation.bottom.displayDimensions(for: (width: 100, height: 200))
        == (width: 100, height: 200),
    )
    #expect(
      ImageOrientation.left.displayDimensions(for: (width: 100, height: 200))
        == (width: 200, height: 100),
    )
    #expect(
      ImageOrientation.right.displayDimensions(for: (width: 100, height: 200))
        == (width: 200, height: 100),
    )
  }

  @Test
  func mirror() async throws {
    #expect(ImageOrientation.top.mirrored() == .topMirrored)
    #expect(ImageOrientation.topMirrored.mirrored() == .top)
    #expect(ImageOrientation.bottom.mirrored() == .bottomMirrored)
    #expect(ImageOrientation.bottomMirrored.mirrored() == .bottom)
    #expect(ImageOrientation.left.mirrored() == .rightMirrored)
    #expect(ImageOrientation.leftMirrored.mirrored() == .right)
    #expect(ImageOrientation.right.mirrored() == .leftMirrored)
    #expect(ImageOrientation.rightMirrored.mirrored() == .left)
  }

  @Test
  func rotateClockwise() async throws {
    #expect(ImageOrientation.top.rotateClockwise() == .right)
    #expect(ImageOrientation.right.rotateClockwise() == .bottom)
    #expect(ImageOrientation.bottom.rotateClockwise() == .left)
    #expect(ImageOrientation.left.rotateClockwise() == .top)
    #expect(ImageOrientation.topMirrored.rotateClockwise() == .rightMirrored)
    #expect(ImageOrientation.rightMirrored.rotateClockwise() == .bottomMirrored)
    #expect(ImageOrientation.bottomMirrored.rotateClockwise() == .leftMirrored)
    #expect(ImageOrientation.leftMirrored.rotateClockwise() == .topMirrored)
  }

  @Test
  func rotateCounterClockwise() async throws {
    #expect(ImageOrientation.top.rotateCounterClockwise() == .left)
    #expect(ImageOrientation.right.rotateCounterClockwise() == .top)
    #expect(ImageOrientation.bottom.rotateCounterClockwise() == .right)
    #expect(ImageOrientation.left.rotateCounterClockwise() == .bottom)
    #expect(ImageOrientation.topMirrored.rotateCounterClockwise() == .leftMirrored)
    #expect(ImageOrientation.rightMirrored.rotateCounterClockwise() == .topMirrored)
    #expect(ImageOrientation.bottomMirrored.rotateCounterClockwise() == .rightMirrored)
    #expect(ImageOrientation.leftMirrored.rotateCounterClockwise() == .bottomMirrored)
  }

  @Test
  func rotate180Degrees() async throws {
    #expect(ImageOrientation.top.rotate180() == .bottom)
    #expect(ImageOrientation.right.rotate180() == .left)
    #expect(ImageOrientation.bottom.rotate180() == .top)
    #expect(ImageOrientation.left.rotate180() == .right)
    #expect(ImageOrientation.topMirrored.rotate180() == .bottomMirrored)
    #expect(ImageOrientation.rightMirrored.rotate180() == .leftMirrored)
    #expect(ImageOrientation.bottomMirrored.rotate180() == .topMirrored)
    #expect(ImageOrientation.leftMirrored.rotate180() == .rightMirrored)
  }

  @Test
  func rotationConsistency() async throws {
    #expect(ImageOrientation.top.rotate180().rotate180() == .top)
    #expect(
      ImageOrientation.left.rotateClockwise().rotateClockwise() == ImageOrientation.left.rotate180()
    )
    #expect(
      ImageOrientation.right.rotateClockwise().rotateCounterClockwise() == ImageOrientation.right
    )
  }
}
