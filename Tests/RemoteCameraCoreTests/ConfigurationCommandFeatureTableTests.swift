import Testing

@testable import RemoteCameraCore

@Suite("Configureation command feature table tests")
struct name {

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

}
