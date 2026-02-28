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
}
