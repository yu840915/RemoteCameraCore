import RemoteCameraCore
import Testing

struct TimelapseRecordingSettingsTests {

  @Test(
    arguments: zip(
      [RationalDuration(value: 1, scale: 10), RationalDuration(value: 1, scale: 1)],
      [10.0, 1.0],
    ),
  )
  func estimateFrameRateFromFrameDuration(
    _ frameDuration: RationalDuration,
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
        RationalDuration(value: 2, scale: 30), RationalDuration(value: 6, scale: 30),
        RationalDuration(value: 7, scale: 30), RationalDuration(value: 1, scale: 30),
      ],
    ),
  )
  func testEstimateTimeLapseDuration(
    _ recordingDuration: Duration,
    _ tsDuration: RationalDuration
  )
    async throws
  {
    let sut = TimelapseRecordingSettings(
      interval: .seconds(10),
      frameDuration: RationalDuration(frameRate: 30),
    )

    #expect(sut.estimateTimeLapseDuration(from: recordingDuration) == tsDuration)
  }

  @Test
  func intervalMustNotBeLessThanFrameDuration() async throws {
    let sut = TimelapseRecordingSettings(
      interval: Duration.milliseconds(100),
      frameDuration: RationalDuration(value: 1, scale: 5),
    )

    #expect(sut.interval == Duration.milliseconds(200))
  }
}
