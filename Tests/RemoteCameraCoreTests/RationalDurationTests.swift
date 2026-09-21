import Testing

@testable import RemoteCameraCore

struct RationalDurationTests {
  @Test(arguments: [DurationScale(24), 25, 30, 60, 120, 240])
  func frameRateRoundTrip(_ frameRate: DurationScale) async throws {
    let sut = RationalDuration(frameRate: frameRate)

    #expect(sut.value == 1)
    #expect(sut.scale == frameRate)
    #expect(sut.frameRate == Double(frameRate))
    #expect(sut.isValid)
  }

  @Test
  func equalLengthsAtDifferentScalesAreEqual() async throws {
    let sut = RationalDuration(frameRate: 30)

    #expect(sut == RationalDuration(value: 2, scale: 60))
    #expect(sut == RationalDuration(value: 20, scale: 600))
    #expect(sut == RationalDuration(value: 100, scale: 3_000))
    #expect(sut != RationalDuration(frameRate: 60))
    #expect(sut != RationalDuration(value: 33_333_333, scale: 1_000_000_000))
  }

  @Test
  func equalLengthsHashAlike() async throws {
    let lengths: Set<RationalDuration> = [
      RationalDuration(frameRate: 30),
      RationalDuration(value: 2, scale: 60),
      RationalDuration(value: 20, scale: 600),
      RationalDuration(frameRate: 60),
    ]

    #expect(lengths.count == 2)
  }

  @Test
  func ordersByLengthAcrossScales() async throws {
    #expect(RationalDuration(frameRate: 60) < RationalDuration(frameRate: 30))
    #expect(RationalDuration(value: 1, scale: 600) < RationalDuration(value: 2, scale: 600))
    #expect(!(RationalDuration(value: 2, scale: 60) < RationalDuration(frameRate: 30)))
  }

  @Test
  func rangeContainsEndpointsStatedAtAnotherScale() async throws {
    let sut = ValueRange(
      min: RationalDuration(frameRate: 60),
      max: RationalDuration(frameRate: 30)
    )

    #expect(sut.contains(RationalDuration(value: 1, scale: 60)))
    #expect(sut.contains(RationalDuration(value: 20, scale: 600)))
    #expect(sut.contains(RationalDuration(value: 25, scale: 1_000)))
    #expect(!sut.contains(RationalDuration(frameRate: 120)))
    #expect(!sut.contains(RationalDuration(frameRate: 15)))
  }

  @Test
  func largeValuesDoNotOverflowComparison() async throws {
    let nanoseconds = RationalDuration(value: 9_000_000_000, scale: 1_000_000_000)
    let seconds = RationalDuration(value: 9, scale: 1)

    #expect(nanoseconds == seconds)
    #expect(RationalDuration(value: 8_999_999_999, scale: 1_000_000_000) < seconds)
  }

  @Test
  func negativeScaleFoldsIntoValue() async throws {
    let sut = RationalDuration(value: 1, scale: -30)

    #expect(sut.value == -1)
    #expect(sut.scale == 30)
    #expect(sut.isValid)
  }

  @Test
  func nonPositiveScaleIsInvalid() async throws {
    let sut = RationalDuration(value: 1, scale: 0)

    #expect(!sut.isValid)
    #expect(sut.seconds == 0)
    #expect(sut.frameRate == 0)
    // Invalid values say nothing about length, so they tie with each other and
    // sort before every real one.
    #expect(sut == RationalDuration(value: 99, scale: 0))
    #expect(sut < RationalDuration.zero)
  }

  @Test
  func zeroIsShorterThanEveryFrameDuration() async throws {
    #expect(RationalDuration.zero < RationalDuration(frameRate: 240))
    #expect(RationalDuration.zero.seconds == 0)
    #expect(RationalDuration.zero.frameRate == 0)
  }

  @Test(arguments: [DurationScale(24), 25, 30, 60, 120, 240])
  func bridgesToDurationAtAttosecondPrecision(_ frameRate: DurationScale) async throws {
    let sut = RationalDuration(frameRate: frameRate).duration

    #expect(sut.components.seconds == 0)
    #expect(sut.components.attoseconds == 1_000_000_000_000_000_000 / Int64(frameRate))
  }

  @Test
  func bridgesWholeAndFractionalSecondsToDuration() async throws {
    #expect(RationalDuration(value: 7, scale: 2).duration == .seconds(3.5))
    #expect(RationalDuration(value: 1, scale: 0).duration == .zero)
  }
}
