import Testing

@testable import RemoteCameraCore

struct AspectRatioTests {
  @Test
  func equalShapesAtDifferentScalesAreEqual() async throws {
    #expect(AspectRatio.widescreen == AspectRatio(width: 1920, height: 1080))
    #expect(AspectRatio.standard == AspectRatio(width: 1440, height: 1080))
    #expect(AspectRatio.square == AspectRatio(width: 1080, height: 1080))
    #expect(AspectRatio.widescreen != AspectRatio.standard)
  }

  @Test
  func equalShapesHashAlike() async throws {
    let shapes: Set<AspectRatio> = [
      .widescreen,
      AspectRatio(width: 1920, height: 1080),
      AspectRatio(width: 3840, height: 2160),
      .standard,
      .square,
    ]

    #expect(shapes.count == 3)
  }

  @Test
  func ordersNarrowerBeforeWider() async throws {
    #expect(AspectRatio.square < AspectRatio.standard)
    #expect(AspectRatio.standard < AspectRatio.widescreen)
    #expect(!(AspectRatio(width: 1920, height: 1080) < AspectRatio.widescreen))
  }

  @Test
  func transposedShapeIsNotTheSameShape() async throws {
    #expect(AspectRatio(width: 3, height: 4) != AspectRatio.standard)
    #expect(AspectRatio(width: 3, height: 4) < AspectRatio.standard)
  }

  @Test(arguments: [
    AspectRatio(width: 0, height: 9),
    AspectRatio(width: 16, height: 0),
    AspectRatio(width: -16, height: 9),
  ])
  func nonPositiveSidesAreInvalid(_ sut: AspectRatio) async throws {
    #expect(!sut.isValid)
    #expect(sut.ratio == 0)
    #expect(sut == AspectRatio(width: 0, height: 0))
    #expect(sut < AspectRatio.square)
  }

  @Test
  func dimensionsReportTheirOwnShape() async throws {
    #expect(ImageDimensions(width: 1920, height: 1080).aspectRatio == .widescreen)
    #expect(ImageDimensions(width: 4032, height: 3024).aspectRatio == .standard)
    #expect(
      ImageDimensions(width: 1080, height: 1920).aspectRatio == AspectRatio(width: 9, height: 16))
  }
}
