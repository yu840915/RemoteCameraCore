import RemoteCameraCore
import Testing

struct TaskProgressTests {
  @Test
  func initialization() async throws {
    let sut = TaskProgress(
      finished: 0,
      total: 100
    )

    #expect(sut.finished == 0)
    #expect(sut.total == 100)
    #expect(sut.fractionCompleted == 0)
    #expect(sut.isComplete == false)
    #expect(sut.hasStarted == false)
  }

  @Test
  func maxFinishedIsTotal() async throws {
    let sut = TaskProgress(
      finished: 200,
      total: 100
    )

    #expect(sut.finished == 100)
    #expect(sut.total == 100)
  }

  @Test
  func fractionCompleted() async throws {
    let sut = TaskProgress(
      finished: 50,
      total: 100
    )

    #expect(sut.fractionCompleted == 0.5)
  }

  @Test
  func isComplete() async throws {
    let sut = TaskProgress(
      finished: 100,
      total: 100
    )

    #expect(sut.isComplete == true)
  }

  @Test
  func hasStarted() async throws {
    let sut = TaskProgress(
      finished: 1,
      total: 100
    )

    #expect(sut.hasStarted == true)
  }

  @Test
  func updateFinished() async throws {
    var sut = TaskProgress(
      finished: 0,
      total: 100
    )

    sut.finished = 50

    #expect(sut.finished == 50)
    #expect(sut.fractionCompleted == 0.5)
    #expect(sut.isComplete == false)
    #expect(sut.hasStarted == true)
  }

  @Test
  func capValueForFinishedUpdate() async throws {
    var sut = TaskProgress(
      finished: 0,
      total: 100
    )

    sut.finished = 200

    #expect(sut.finished == 100)
    #expect(sut.total == 100)
  }

  @Test
  func summation() async throws {
    let progress1 = TaskProgress(
      finished: 50,
      total: 100
    )
    let progress2 = TaskProgress(
      finished: 30,
      total: 100
    )

    let sut = progress1 + progress2

    #expect(sut.finished == 80)
    #expect(sut.total == 200)
  }
}
