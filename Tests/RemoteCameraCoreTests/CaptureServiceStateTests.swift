import RemoteCameraCore
import Testing

struct CaptureServiceStateTests {
  @Test("Torch modes", arguments: [TorchMode.auto, .on, .off])
  func fullTorchModes(_ mode: TorchMode) async throws {
    var sut = CaptureServiceState()
    sut.capabilities.torchModes = [.auto, .on, .off]

    sut.availableConfigurationCommands.setTorchMode = false
    #expect(!sut.canPerform(.setTorchMode(mode: mode)))

    sut.availableConfigurationCommands.setTorchMode = true
    #expect(sut.canPerform(.setTorchMode(mode: mode)))
  }

  @Test
  func incompleteTorchModes() async throws {
    var sut = CaptureServiceState()
    sut.availableConfigurationCommands.setTorchMode = true

    sut.capabilities.torchModes = [.off]

    #expect(!sut.canPerform(.setTorchMode(mode: .auto)))
    #expect(!sut.canPerform(.setTorchMode(mode: .on)))
    #expect(sut.canPerform(.setTorchMode(mode: .off)))
  }

  @Test("Flash modes", arguments: [FlashMode.auto, .on, .off])
  func fullFlashModes(_ mode: FlashMode) async throws {
    var sut = CaptureServiceState()
    sut.capabilities.flashModes = [.auto, .on, .off]

    sut.availableConfigurationCommands.setFlashMode = false
    #expect(!sut.canPerform(.setFlashMode(mode: mode)))

    sut.availableConfigurationCommands.setFlashMode = true
    #expect(sut.canPerform(.setFlashMode(mode: mode)))
  }

  @Test
  func incompleteFlashModes() async throws {
    var sut = CaptureServiceState()
    sut.availableConfigurationCommands.setFlashMode = true

    sut.capabilities.flashModes = [.off]

    #expect(!sut.canPerform(.setFlashMode(mode: .auto)))
    #expect(!sut.canPerform(.setFlashMode(mode: .on)))
    #expect(sut.canPerform(.setFlashMode(mode: .off)))
  }

  @Test("Exposure modes", arguments: [ExposureMode.auto, .locked])
  func fullExposureModes(_ mode: ExposureMode) async throws {
    var sut = CaptureServiceState()
    sut.capabilities.exposureModes = [.auto, .locked]

    sut.availableConfigurationCommands.setExposureMode = false
    #expect(!sut.canPerform(.setExposureMode(mode: mode)))

    sut.availableConfigurationCommands.setExposureMode = true
    #expect(sut.canPerform(.setExposureMode(mode: mode)))
  }

  @Test func incompleteExposureModes() async throws {
    var sut = CaptureServiceState()
    sut.availableConfigurationCommands.setExposureMode = true

    sut.capabilities.exposureModes = [.locked]

    #expect(!sut.canPerform(.setExposureMode(mode: .auto)))
    #expect(sut.canPerform(.setExposureMode(mode: .locked)))
  }

  @Test("Focus modes", arguments: [FocusMode.auto, .locked])
  func fullFocusModes(_ mode: FocusMode) async throws {
    var sut = CaptureServiceState()
    sut.capabilities.focusModes = [.auto, .locked]

    sut.availableConfigurationCommands.setFocusMode = false
    #expect(!sut.canPerform(.setFocusMode(mode: mode)))

    sut.availableConfigurationCommands.setFocusMode = true
    #expect(sut.canPerform(.setFocusMode(mode: mode)))
  }

  @Test func incompleteFocusModes() async throws {
    var sut = CaptureServiceState()
    sut.availableConfigurationCommands.setFocusMode = true

    sut.capabilities.focusModes = [.locked]

    #expect(!sut.canPerform(.setFocusMode(mode: .auto)))
    #expect(sut.canPerform(.setFocusMode(mode: .locked)))
  }

  @Test
  func lockWhiteBalanceWithGrayWorld() async throws {
    var sut = CaptureServiceState()
    sut.capabilities.whiteBalanceModes = [.locked, .auto]

    sut.availableConfigurationCommands.lockWhiteBalanceWithGrayWorld = false
    #expect(!sut.canPerform(.lockWhiteBalanceWithGrayWorld))

    sut.availableConfigurationCommands.lockWhiteBalanceWithGrayWorld = true
    #expect(sut.canPerform(.lockWhiteBalanceWithGrayWorld))
  }

  @Test
  func disableWhiteBalanceGrayWorldLockIfNoLockMode() async throws {
    var sut = CaptureServiceState()

    sut.capabilities.whiteBalanceModes = [.auto]
    sut.availableConfigurationCommands.lockWhiteBalanceWithGrayWorld = true

    #expect(!sut.canPerform(.lockWhiteBalanceWithGrayWorld))
  }

  @Test("Zoom factor within range", arguments: [0.5, 1, 5])
  func zoomFactorWithinRange(_ factor: Double) async throws {
    var sut = CaptureServiceState()
    sut.capabilities.zoomFactorRange = ValueRange(min: 0, max: 5)

    sut.availableConfigurationCommands.setZoomFactor = false
    #expect(!sut.canPerform(.setZoomFactor(factor: factor)))

    sut.availableConfigurationCommands.setZoomFactor = true
    #expect(sut.canPerform(.setZoomFactor(factor: factor)))
  }

  @Test("Zoom factor out of range", arguments: [0, 6])
  func zoomFactorOutOfRange(_ factor: Double) async throws {
    var sut = CaptureServiceState()
    sut.availableConfigurationCommands.setZoomFactor = true

    sut.capabilities.zoomFactorRange = ValueRange(min: 1, max: 5)

    #expect(!sut.canPerform(.setZoomFactor(factor: factor)))
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
    var sut = CaptureServiceState()

    sut.availableConfigurationCommands.setFocusPointOfInterest = false
    #expect(!sut.canPerform(.setFocusPointOfInterest(point: point)))

    sut.availableConfigurationCommands.setFocusPointOfInterest = true
    #expect(sut.canPerform(.setFocusPointOfInterest(point: point)))
  }

  @Test(
    "WB Temp & Tint",
    arguments: [
      TemperatureAndTint(temperature: 5000, tint: 0),
      .init(temperature: 3000, tint: -0.5),
      .init(temperature: 7000, tint: 0.5),
    ])
  func temperatureAndTintWithinRange(_ value: TemperatureAndTint) async throws {
    var sut = CaptureServiceState()
    sut.capabilities.whiteBalanceModes = [.locked, .auto]
    sut.capabilities.whiteBalanceTemperatureRange = ValueRange(min: 2000, max: 8000)
    sut.capabilities.whiteBalanceTintRange = ValueRange(min: -1, max: 1)

    sut.availableConfigurationCommands.setTemperatureAndTint = false
    #expect(!sut.canPerform(.setTemperatureAndTint(value: value)))

    sut.availableConfigurationCommands.setTemperatureAndTint = true
    #expect(sut.canPerform(.setTemperatureAndTint(value: value)))

    sut.capabilities.whiteBalanceModes = [.auto]
    #expect(!sut.canPerform(.setTemperatureAndTint(value: value)))
  }

  @Test(
    "WB Temp & Tint out of range",
    arguments: [
      TemperatureAndTint(temperature: 10000, tint: 0),
      .init(temperature: 3000, tint: -1.5),
      .init(temperature: 0, tint: 0.5),
      .init(temperature: 3000, tint: 2),
    ])
  func temperatureAndTintOutOfRange(_ value: TemperatureAndTint) async throws {
    var sut = CaptureServiceState()
    sut.availableConfigurationCommands.setTemperatureAndTint = true
    sut.capabilities.whiteBalanceModes = [.locked, .auto]

    sut.capabilities.whiteBalanceTemperatureRange = ValueRange(min: 2000, max: 8000)
    sut.capabilities.whiteBalanceTintRange = ValueRange(min: -1, max: 1)

    #expect(!sut.canPerform(.setTemperatureAndTint(value: value)))
  }

  @Test(
    "Lens position within range",
    arguments: [0.0, 0.5, 1.0]
  )
  func lensPositionWithinRange(_ pos: Double) async throws {
    var sut = CaptureServiceState()
    sut.capabilities.lensPositionRange = .init(min: 0, max: 1)

    sut.availableConfigurationCommands.setLensPosition = false
    #expect(!sut.canPerform(.setLensPosition(position: pos)))

    sut.availableConfigurationCommands.setLensPosition = true
    #expect(sut.canPerform(.setLensPosition(position: pos)))
  }

  @Test(
    "Lens position out of range",
    arguments: [-0.1, 1.1]
  )
  func lensPositionOutOfRange(_ pos: Double) async throws {
    var sut = CaptureServiceState()
    sut.availableConfigurationCommands.setLensPosition = true

    sut.capabilities.lensPositionRange = .init(min: 0, max: 1)

    #expect(!sut.canPerform(.setLensPosition(position: pos)))
  }

  @Test(
    "Exposure duration within range",
    arguments: [0.1, 0.5, 1.0]
  )
  func exposureDurationWithRange(_ duration: Double) async throws {
    var sut = CaptureServiceState()
    sut.capabilities.exposureDurationRange = .init(min: 0.01, max: 1.0)

    sut.availableConfigurationCommands.setExposureDuration = false
    #expect(!sut.canPerform(.setExposureDuration(seconds: duration)))

    sut.availableConfigurationCommands.setExposureDuration = true
    #expect(sut.canPerform(.setExposureDuration(seconds: duration)))
  }

  @Test(
    "Exposure duration out of range",
    arguments: [0.0, 1.1]
  )
  func exposureDurationOutOfRange(_ duration: Double) async throws {
    var sut = CaptureServiceState()
    sut.availableConfigurationCommands.setExposureDuration = true

    sut.capabilities.exposureDurationRange = .init(min: 0.01, max: 1.0)

    #expect(!sut.canPerform(.setExposureDuration(seconds: duration)))
  }

  @Test(
    "ISO within range",
    arguments: [100, 200, 400]
  )
  func isoWithinRange(_ value: Double) async throws {
    var sut = CaptureServiceState()
    sut.capabilities.isoRange = .init(min: 100, max: 800)

    sut.availableConfigurationCommands.setISO = false
    #expect(!sut.canPerform(.setISO(iso: value)))

    sut.availableConfigurationCommands.setISO = true
    #expect(sut.canPerform(.setISO(iso: value)))
  }

  @Test(
    "ISO out of range",
    arguments: [50, 900]
  )
  func isoOutOfRange(_ value: Double) async throws {
    var sut = CaptureServiceState()
    sut.availableConfigurationCommands.setISO = true

    sut.capabilities.isoRange = .init(min: 100, max: 800)

    #expect(!sut.canPerform(.setISO(iso: value)))
  }
}
