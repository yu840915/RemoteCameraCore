import RemoteCameraCore
import Testing

struct DeviceOrientationTests {
  @Test(nil, arguments: [Double.pi, -.pi, 3 * .pi, -3 * .pi])
  func convertHeadingInput(_ heading: Double) async throws {
    let orientation = DeviceOrientation(heading: heading, pitch: 0)

    #expect(orientation.heading == Double.pi)
  }

  @Test(
    nil,
    arguments: [Double.pi / 2, (Double.pi / 2) + 2 * .pi, (Double.pi / 2) - 2 * .pi],
  )
  func convertAngledHeadingInput(_ heading: Double) async throws {
    let orientation = DeviceOrientation(heading: heading, pitch: 0)

    #expect(orientation.heading == (Double.pi / 2.0))
  }

  @Test(
    nil,
    arguments: [Double.pi / 2, -3 * (Double.pi / 2), 5 * (Double.pi / 2), -7 * (Double.pi / 2)],
  )
  func convertPitchFacingUpInput(_ heading: Double) async throws {
    let orientation = DeviceOrientation(heading: 0, pitch: heading)

    #expect(orientation.pitch == (Double.pi / 2.0))
  }

  @Test(
    nil,
    arguments: [-Double.pi / 2, -3 * (-Double.pi / 2), 5 * (-Double.pi / 2), -7 * (-Double.pi / 2)])
  func convertPitchFacingDownInput(_ heading: Double) async throws {
    let orientation = DeviceOrientation(heading: 0, pitch: heading)

    #expect(orientation.pitch == (-Double.pi / 2.0))
  }

  @Test(
    nil,
    arguments: [
      Double.pi / 4, 3 * (Double.pi / 4), (Double.pi / 4) + 2 * .pi, (Double.pi / 4) - 2 * .pi,
    ])
  func convertFacing45UpInput(_ heading: Double) async throws {
    let orientation = DeviceOrientation(heading: 0, pitch: heading)

    #expect(orientation.pitch == (Double.pi / 4.0))
  }

  @Test(
    nil,
    arguments: [
      -Double.pi / 4, 3 * (-Double.pi / 4), (-Double.pi / 4) + 2 * .pi, (-Double.pi / 4) - 2 * .pi,
    ])
  func convertFacing45DownInput(_ heading: Double) async throws {
    let orientation = DeviceOrientation(heading: 0, pitch: heading)

    #expect(orientation.pitch == (-Double.pi / 4.0))
  }

  @Test(nil, arguments: [0, Double.pi / 4, Double.pi / 2, 0.001, Double.pi, 3 * Double.pi / 2])
  func approximatelyOpposite(_ heading: Double) async throws {
    let sut = DeviceOrientation(heading: heading, pitch: 0)

    #expect(
      sut.isArroximatelyOpposite(
        to: DeviceOrientation(heading: heading + .pi / 2 + 0.001, pitch: 0)))
    #expect(
      sut.isArroximatelyOpposite(
        to: DeviceOrientation(heading: heading + 3 * .pi / 2 - 0.001, pitch: 0)))
    #expect(sut.isArroximatelyOpposite(to: DeviceOrientation(heading: heading + .pi, pitch: 0)))
  }

  @Test(nil, arguments: [0, Double.pi / 4, Double.pi / 2, 0.001, Double.pi, 3 * Double.pi / 2])
  func oppositeInPitch(_ heading: Double) async throws {
    #expect(
      DeviceOrientation(
        heading: 0, pitch: .pi / 2
      ).isArroximatelyOpposite(
        to: DeviceOrientation(heading: heading, pitch: -.pi / 2),
      ),
    )
    #expect(
      DeviceOrientation(
        heading: 0, pitch: .pi / 2 - .pi / 6 + 0.001
      ).isArroximatelyOpposite(
        to: DeviceOrientation(
          heading: heading, pitch: -.pi / 2 + .pi / 6 - 0.001
        ),
      ),
    )
  }

  @Test
  func opposite() async throws {
    #expect(
      DeviceOrientation(heading: .pi / 4, pitch: .pi / 4).opposite
        == DeviceOrientation(heading: 5 * .pi / 4, pitch: -.pi / 4)
    )
    #expect(
      DeviceOrientation(heading: 3 * .pi / 2, pitch: 0).opposite
        == DeviceOrientation(heading: .pi / 2, pitch: 0)
    )
  }

  @Test(
    nil,
    arguments: [(Double, Double)]([
      (0.0, Double.pi / 2),
      (30.0, Double.pi / 3),
      (90.0, 0),
      (135.0, 7 * Double.pi / 4),
      (180.0, 3 * Double.pi / 2),
      (-180.0, 3 * Double.pi / 2),
      (540.0, 3 * Double.pi / 2),
    ]),
  )
  func initWithCompassHeading(compassHeading: Double, heading: Double) async throws {
    let sut = DeviceOrientation(compassHeading: compassHeading, pitch: 0)

    #expect(sut.heading == heading)
  }

  @Test
  func forwardIsOppositeToBackward() async throws {
    #expect(DeviceOrientation.virtualForward.heading == 0)
    #expect(DeviceOrientation.virtualBackward.heading == 0)
    #expect(DeviceOrientation.virtualForward.pitch == 0)
    #expect(DeviceOrientation.virtualBackward.pitch == 0)
    #expect(
      DeviceOrientation.virtualForward.isArroximatelyOpposite(to: DeviceOrientation.virtualBackward)
    )
  }

  @Test(
    nil,
    arguments: [
      0,
      Double.pi / 4,
      Double.pi / 2,
      0.001,
      Double.pi,
      3 * Double.pi / 2,
    ]
  )
  func virtualForwardNeverBeOppositeToPhysical(heading: Double) async throws {
    let sut = DeviceOrientation(heading: heading, pitch: 0)

    #expect(!DeviceOrientation.virtualForward.isArroximatelyOpposite(to: sut))
  }

  @Test(
    nil,
    arguments: [
      0,
      Double.pi / 4,
      Double.pi / 2,
      0.001,
      Double.pi,
      3 * Double.pi / 2,
    ]
  )
  func virtualBackwardNeverBeOppositeToPhysical(heading: Double) async throws {
    let sut = DeviceOrientation(heading: heading, pitch: 0)

    #expect(!DeviceOrientation.virtualBackward.isArroximatelyOpposite(to: sut))
  }
}
