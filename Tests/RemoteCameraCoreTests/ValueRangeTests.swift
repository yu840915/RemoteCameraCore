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
}
