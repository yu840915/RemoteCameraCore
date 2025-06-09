import Testing

@testable import RemoteCameraCore

@Suite("Configureation command feature table tests")
struct name {

  @Test("Torch modes", arguments: [TorchMode.auto, .on, .off])
  func testSetTorchMode(_ mode: TorchMode) async throws {
    var sut = CaptureServiceCommand.ConfigurationCommand.FeatureTable()

    sut.setTorchMode = false
    #expect(!sut.canPerform(.setTorchMode(mode: mode)))

    sut.setTorchMode = true
    #expect(sut.canPerform(.setTorchMode(mode: mode)))
  }

  @Test("Flash modes", arguments: [FlashMode.auto, .on, .off])
  func testSetFlashMode(_ mode: FlashMode) async throws {
    var sut = CaptureServiceCommand.ConfigurationCommand.FeatureTable()

    sut.setFlashMode = false
    #expect(!sut.canPerform(.setFlashMode(mode: mode)))

    sut.setFlashMode = true
    #expect(sut.canPerform(.setFlashMode(mode: mode)))
  }

  @Test("Zoom factor", arguments: [0.5, 1, 5])
  func testSetZoomFactor(_ factor: Double) async throws {
    var sut = CaptureServiceCommand.ConfigurationCommand.FeatureTable()

    sut.setZoomFactor = false
    #expect(!sut.canPerform(.setZoomFactor(factor: factor)))

    sut.setZoomFactor = true
    #expect(sut.canPerform(.setZoomFactor(factor: factor)))
  }

  @Test(
    "Focus PoI",
    arguments: [
      Point(x: 0.5, y: 0.5),
      Point(x: 0.1, y: 0.9),
      Point(x: 0.9, y: 0.1),
      Point(x: 0, y: 0),
      Point(x: 1, y: 1),
    ])
  func testSetFocusPointOfInterest(_ point: Point) async throws {
    var sut = CaptureServiceCommand.ConfigurationCommand.FeatureTable()

    sut.setFocusPointOfInterest = false
    #expect(!sut.canPerform(.setFocusPointOfInterest(point: point)))

    sut.setFocusPointOfInterest = true
    #expect(sut.canPerform(.setFocusPointOfInterest(point: point)))
  }

  @Test(
    "WB Temp & Tint",
    arguments: [
      TemperatureAndTint(temperature: 5000, tint: 0), .init(temperature: 3000, tint: -0.5),
      .init(temperature: 7000, tint: 0.5),
    ])
  func testSetTemperatureAndTint(_ value: TemperatureAndTint) async throws {
    var sut = CaptureServiceCommand.ConfigurationCommand.FeatureTable()

    sut.setTemperatureAndTint = false
    #expect(!sut.canPerform(.setTemperatureAndTint(value: value)))

    sut.setTemperatureAndTint = true
    #expect(sut.canPerform(.setTemperatureAndTint(value: value)))
  }

  @Test
  func testLockWhiteBalanceWithGrayWorld() async throws {
    var sut = CaptureServiceCommand.ConfigurationCommand.FeatureTable()

    sut.lockWhiteBalanceWithGrayWorld = false
    #expect(!sut.canPerform(.lockWhiteBalanceWithGrayWorld))

    sut.lockWhiteBalanceWithGrayWorld = true
    #expect(sut.canPerform(.lockWhiteBalanceWithGrayWorld))
  }

  @Test
  func enableAll() async throws {
    var sut = CaptureServiceCommand.ConfigurationCommand.FeatureTable()

    sut.enableAll()

    #expect(sut.setLivePhoto)
    #expect(sut.setTorchMode)
    #expect(sut.setFlashMode)
    #expect(sut.setZoomFactor)
    #expect(sut.smoothZoom)
    #expect(sut.setHDR)
    #expect(sut.setFocusMode)
    #expect(sut.setLensPosition)
    #expect(sut.setFocusPointOfInterest)
    #expect(sut.setExposureMode)
    #expect(sut.setExposurePointOfInterest)
    #expect(sut.setExposureDuration)
    #expect(sut.setISO)
    #expect(sut.setWhiteBalanceMode)
    #expect(sut.setTemperatureAndTint)
    #expect(sut.setWhiteBalanceGains)
    #expect(sut.lockWhiteBalanceWithGrayWorld)
  }

  @Test
  func disableFeaturesOnDummyCapability() async throws {
    var sut = CaptureServiceCommand.ConfigurationCommand.FeatureTable()
    sut.enableAll()

    sut.disableFeature(on: CameraCapabilities())

    #expect(sut.setLivePhoto)
    #expect(!sut.setTorchMode)
    #expect(!sut.setFlashMode)
    #expect(!sut.setZoomFactor)
    #expect(!sut.smoothZoom)
    #expect(sut.setHDR)
    #expect(!sut.setFocusMode)
    #expect(!sut.setLensPosition)
    #expect(sut.setFocusPointOfInterest)
    #expect(!sut.setExposureMode)
    #expect(sut.setExposurePointOfInterest)
    #expect(!sut.setExposureDuration)
    #expect(!sut.setISO)
    #expect(!sut.setWhiteBalanceMode)
    #expect(!sut.setTemperatureAndTint)
    #expect(!sut.setWhiteBalanceGains)
    #expect(!sut.lockWhiteBalanceWithGrayWorld)
  }
}
