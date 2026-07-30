extension ImageOrientation {
  /// Maps image content into display space: rotation first, then the mirror the orientation
  /// itself carries.
  ///
  /// - Note: the mirror is applied *after* the rotation, matching the transform the view finder
  ///   layer is driven with. `AVCameraAdapter`'s `affineTransform` applies its mirror *before*
  ///   the rotation, so the two disagree on the four mirrored quarter turns. That one feeds
  ///   `AVAssetWriterInput.transform`; this one is for display and hit-testing.
  public var displayTransform: ImagePlaneTransform {
    let rotation =
      switch self {
      case .top, .topMirrored: ImagePlaneTransform.identity
      case .right, .rightMirrored: ImagePlaneTransform.quarterTurnCounterClockwise
      case .bottom, .bottomMirrored: ImagePlaneTransform.halfTurn
      case .left, .leftMirrored: ImagePlaneTransform.quarterTurnClockwise
      }
    guard isMirrored else {
      return rotation
    }
    return rotation.concatenating(.flippedHorizontally)
  }
}
