import Testing

@testable import RemoteCameraCore

@Suite("ValueRange tests")
struct ValueRangeTests {
  @Test
  func initWithValue() {
    let range = ValueRange(min: 0, max: 100)
    #expect(range.min == 0)
    #expect(range.max == 100)
  }

  @Test
  func throwOnOutOfOrderValues() {
    #expect(throws: Error.self) {
      try ValueRange(checkedMin: 100, max: 0)
    }
  }

  @Test(
    "values, contains",
    arguments: zip([-1, 0, 50, 100, 101], [false, true, true, true, false])
  )
  func contains(value: Int, expected: Bool) {
    let range = ValueRange(min: 0, max: 100)

    #expect(range.contains(value) == expected)
  }

  @Test(
    "values, clamped",
    arguments: zip([-1, 0, 50, 100, 101], [0, 0, 50, 100, 100])
  )
  func clampValue(value: Int, expected: Int) {
    let range = ValueRange(min: 0, max: 100)

    #expect(range.clamp(value) == expected)
  }

  @Test
  func equatable() async throws {
    let range1 = ValueRange(min: 0, max: 100)
    let range2 = ValueRange(min: 0, max: 100)
    let range3 = ValueRange(min: 0, max: 101)

    #expect(range1 == range2)
    #expect(range1 != range3)
  }

  @Test(nil, arguments: [(0, 0.0), (50, 0.0), (100, 0.5), (150, 1.0), (200, 1.0)])
  func proportionalValue(value: Int, expected: Double) async throws {
    let range = ValueRange(min: 50, max: 150)

    #expect(range.proportionalValue(for: value) == expected)
  }
}
