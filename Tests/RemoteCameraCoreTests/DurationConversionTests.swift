import RemoteCameraCore
import Testing

struct DurationConversionTests {
	@Test(
		nil,
		arguments: [(Double, Int64, Int64)]([
			(0, 0, 0),
			(1.25, 1, 250_000_000_000_000_000),
			(-1.25, -1, -250_000_000_000_000_000),
			(0.75, 0, 750_000_000_000_000_000),
			(-0.75, 0, -750_000_000_000_000_000),
		])
	)
	func initFromDoubleProducesExpectedComponents(
		doubleValue: Double,
		expectedSeconds: Int64,
		expectedAttoseconds: Int64,
	) async throws {
		let sut = Duration(doubleValue)

		#expect(sut.components.seconds == expectedSeconds)
		#expect(sut.components.attoseconds == expectedAttoseconds)
	}

	@Test(
		nil,
		arguments: [(Int64, Int64, Double)]([
			(0, 0, 0),
			(2, 500_000_000_000_000_000, 2.5),
			(-2, -500_000_000_000_000_000, -2.5),
			(1, -500_000_000_000_000_000, 0.5),
		])
	)
	func doubleValueFromComponentsProducesExpectedResult(
		seconds: Int64,
		attoseconds: Int64,
		expectedDoubleValue: Double,
	) async throws {
		let sut = Duration(secondsComponent: seconds, attosecondsComponent: attoseconds)

		#expect(sut.doubleValue == expectedDoubleValue)
	}

	@Test(nil, arguments: [0.0, 0.1, -0.1, 1.0 / 3.0, -1.0 / 3.0, 12345.6789, -9876.54321])
	func roundTripDoubleConversion(value: Double) async throws {
		let sut = Duration(value)
		let restored = sut.doubleValue

		let tolerance = max(1e-15, abs(value) * 1e-15)
		#expect(abs(restored - value) <= tolerance)
	}
}
