public struct VideoBufferInfo: Sendable, Equatable {
  public var dimensions: ImageDimensions
  public var orientation: ImageOrientation?
  public let inputDeviceDirection: DeviceDirection?
  public var mirroring: VideoMirroring

  public init(
    dimensions: ImageDimensions,
    orientation: ImageOrientation?,
    inputDeviceDirection: DeviceDirection? = nil,
    mirroring: VideoMirroring = .none
  ) {
    self.dimensions = dimensions
    self.orientation = orientation
    self.inputDeviceDirection = inputDeviceDirection
    self.mirroring = mirroring
  }
}
