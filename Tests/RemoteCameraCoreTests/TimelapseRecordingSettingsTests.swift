import RemoteCameraCore
import Testing

struct TimelapseRecordingSettingsTests {

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
    let sut = TimelapseRecordingSettings(
      interval: .seconds(5),
      frameDuration: frameDuration,
    )

    #expect(abs(sut.frameRate - frameRate) <= 1e-9)
  }

  @Test(
    arguments: zip(
      [
        Duration.seconds(10), Duration.seconds(55), Duration.seconds(60),
        Duration.seconds(1),
      ],
      [
        Duration.milliseconds(200), Duration.milliseconds(600), Duration.milliseconds(700),
        Duration.milliseconds(100),
      ],
    ),
  )
  func testEstimateTimeLapseDuration(
    _ recordingDuration: Duration,
    _ tsDuration: Duration
  )
    async throws
  {
    let sut = TimelapseRecordingSettings(
      interval: .seconds(10),
      frameDuration: Duration.milliseconds(100),
    )

    #expect(sut.estimateTimeLapseDuration(from: recordingDuration) == tsDuration)
  }

  @Test
  func intervalMustNotBeLessThanFrameDuration() async throws {
    let sut = TimelapseRecordingSettings(
      interval: Duration.milliseconds(100),
      frameDuration: Duration.milliseconds(200),
    )

    #expect(sut.interval == Duration.milliseconds(200))
  }
}
