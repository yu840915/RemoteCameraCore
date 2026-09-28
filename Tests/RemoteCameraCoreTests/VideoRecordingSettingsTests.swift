import RemoteCameraCore
import Testing

struct VideoRecordingSettingsTests {
  @Test(
    arguments: zip(
      [
        RationalDuration(value: 1, scale: 10),
        RationalDuration(value: 1, scale: 1),
        RationalDuration(value: 1001, scale: 30000),
      ],
      [
        10.0,
        1.0,
        30000.0 / 1001.0,
      ],
    ),
  )
  func estimateFrameRateFromFrameDuration(
    _ frameDuration: RationalDuration,
    _ frameRate: Double,
  )
    async throws
  {
    let settings = VideoRecordingSettings(frameDuration: frameDuration)

    #expect(abs(settings.frameRate - frameRate) <= 1e-9)
  }

  @Test(
    arguments: zip(
      [
        DurationScale(10),
        DurationScale(1),
        DurationScale(30),
        DurationScale(0),
        DurationScale(-1),
      ],
      [
        RationalDuration(value: 100, scale: 1000),
        RationalDuration(value: 1, scale: 1),
        RationalDuration(value: 1, scale: 30),
        RationalDuration.zero,
        RationalDuration.zero,
      ],
    ),
  )
  func initWithFrameRate(
    _ frameRate: DurationScale,
    _ frameDuration: RationalDuration,
  ) async throws {
    let settings = VideoRecordingSettings(frameRate: frameRate)

    #expect(settings.frameDuration == frameDuration)
  }
}
