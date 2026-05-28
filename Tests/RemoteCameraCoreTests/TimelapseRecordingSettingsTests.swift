import RemoteCameraCore
import Testing

struct TimelapseRecordingSettingsTests {

  @Test(
    arguments: zip(
      [Duration.seconds(0.1), Duration.seconds(1), .zero, Duration.seconds(-1)],
      [10.0, 1.0, 0.0, 0.0],
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

    #expect(sut.frameRate == frameRate)
  }

  @Test(
    arguments: zip(
      [
        Duration.seconds(10), Duration.seconds(55), Duration.seconds(60), .zero,
        Duration.seconds(1), Duration.seconds(-1),
      ],
      [
        Duration.seconds(0.2), Duration.seconds(0.6), Duration.seconds(0.7), .zero,
        Duration.seconds(0.1), .zero,
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
      frameDuration: Duration.seconds(0.1),
    )

    #expect(sut.estimateTimeLapseDuration(from: recordingDuration) == tsDuration)
  }

  @Test
  func intervalMustNotBeLessThanFrameDuration() async throws {
    let sut = TimelapseRecordingSettings(
      interval: Duration.seconds(0.1),
      frameDuration: Duration.seconds(0.2),
    )

    #expect(sut.interval == Duration.seconds(0.2))
  }
}
