import Testing

@testable import RemoteCameraCore

struct NodeStatusMergerTests {
  @Test
  func mergeAllPreparing() async throws {
    let sut = NodeStatusMerger()

    let status = sut.merge(
      [
        .preparing,
        .preparing,
      ],
    )

    #expect(status == .preparing)
  }

  @Test
  func mergeAllCancelled() async throws {
    let sut = NodeStatusMerger()

    let status = sut.merge(
      [
        .cancelled(nil),
        .cancelled(nil),
      ],
    )

    #expect(status == .cancelled(nil))
  }

  @Test
  func mergeAllReady() async throws {
    let sut = NodeStatusMerger()

    let status = sut.merge(
      [
        .ready,
        .ready,
      ],
    )

    #expect(status == .ready)
  }

  @Test
  func cancelledBeforePrepare() async throws {
    let sut = NodeStatusMerger()

    let status1 = sut.merge(
      [
        .cancelled(nil),
        .preparing,
      ],
    )
    let status2 = sut.merge(
      [
        .preparing,
        .cancelled(nil),
      ],
    )

    #expect(status1 == .cancelled(nil))
    #expect(status2 == .cancelled(nil))
  }

  @Test
  func partialPreparing() async throws {
    let sut = NodeStatusMerger()

    let status1 = sut.merge(
      [
        .ready,
        .preparing,
      ],
    )
    let status2 = sut.merge(
      [
        .preparing,
        .ready,
      ],
    )

    #expect(status1 == .preparing)
    #expect(status2 == .preparing)
  }
}
