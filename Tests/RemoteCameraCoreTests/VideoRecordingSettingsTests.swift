import RemoteCameraCore
import Testing

struct VideoRecordingSettingsTests {
  @Test(
    arguments: zip(
      [Duration.seconds(0.1), Duration.seconds(1)],
      [10.0, 1.0],
    ),
  )
  func estimateFrameRateFromFrameDuration(
    _ frameDuration: Duration,
    _ frameRate: Double,
  )
    async throws
  {
    let settings = VideoRecordingSettings(frameDuration: frameDuration)

    #expect(abs(settings.frameRate - frameRate) <= 1e-9)
  }

  @Test(
    arguments: zip(
      [10.0, 1.0, 0.0, -1.0],
      [Duration.milliseconds(100), Duration.seconds(1), .zero, .zero],
    ),
  )
  func initWithFrameRate(
    _ frameRate: Double,
    _ frameDuration: Duration,
  ) async throws {
    let settings = VideoRecordingSettings(frameRate: frameRate)

    #expect(settings.frameDuration == frameDuration)
  }
}
