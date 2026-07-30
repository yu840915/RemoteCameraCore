public struct VideoBufferInfo: Sendable, Equatable {
  public var dimensions: ImageDimensions
  public var orientation: ImageOrientation?
  public var mirroring: VideoMirroring

  public init(
    dimensions: ImageDimensions,
    orientation: ImageOrientation?,
    mirroring: VideoMirroring = .none
  ) {
    self.dimensions = dimensions
    self.orientation = orientation
    self.mirroring = mirroring
  }
}
