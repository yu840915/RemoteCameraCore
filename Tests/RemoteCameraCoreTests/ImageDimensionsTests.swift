import RemoteCameraCore
import Testing

struct ImageDimensionsTests {
  @Test
  func publicInit() async throws {
    let sut = ImageDimensions(width: 100, height: 200)

    #expect(sut.width == 100)
    #expect(sut.height == 200)
  }

  @Test
  func transpose() async throws {
    let sut = ImageDimensions(width: 100, height: 200)
    let transposed = sut.transposed()

    #expect(transposed.width == 200)
    #expect(transposed.height == 100)
  }

  @Test
  func isPortrait() async throws {
    #expect(ImageDimensions(width: 100, height: 200).isPortrait == true)

    #expect(ImageDimensions(width: 200, height: 100).isPortrait == false)

    #expect(ImageDimensions(width: 100, height: 100).isPortrait == false)
  }

  @Test
  func isLandscape() async throws {
    #expect(ImageDimensions(width: 200, height: 100).isLandscape == true)

    #expect(ImageDimensions(width: 100, height: 200).isLandscape == false)

    #expect(ImageDimensions(width: 100, height: 100).isLandscape == false)
  }

  @Test
  func isSquare() async throws {
    #expect(ImageDimensions(width: 100, height: 100).isSquare == true)

    #expect(ImageDimensions(width: 200, height: 100).isSquare == false)

    #expect(ImageDimensions(width: 100, height: 200).isSquare == false)
  }
}
