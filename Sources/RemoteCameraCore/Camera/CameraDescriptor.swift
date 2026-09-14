public struct CameraDescriptor: Sendable, Equatable {
  public let id: String
  public let name: String
  public let position: CameraPosition
  public let focalLength: Double?
  public let aperture: Double?

  public init(
    id: String,
    name: String,
    position: CameraPosition,
    focalLength: Double? = nil,
    aperture: Double? = nil
  ) {
    self.id = id
    self.name = name
    self.position = position
    self.focalLength = focalLength
    self.aperture = aperture
  }
}

extension CameraDescriptor: CustomStringConvertible {
  public var description: String {
    return
      "Camera(id: \(id), name: \(name), position: \(position), focalLength: \(focalLength ?? 0.0), aperture: \(aperture ?? 0.0))"
  }
}
