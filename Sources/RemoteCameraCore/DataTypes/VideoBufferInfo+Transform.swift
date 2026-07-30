extension VideoBufferInfo {
  /// Orientation and mirroring combined.
  ///
  /// The single source of truth for how this buffer is turned to face the viewer. Both the view
  /// finder's layer transform and point-of-interest mapping derive from it, so the preview and
  /// the touch target cannot drift apart.
  public var orientationTransform: ImagePlaneTransform {
    let base = orientation?.displayTransform ?? .identity
    return switch mirroring {
    case .none: base
    case .horizontal: base.concatenating(.flippedHorizontally)
    case .vertical: base.concatenating(.flippedVertically)
    case .both: base.concatenating(.halfTurn)
    }
  }

  /// Where a point of interest reported by the camera lands on the view finder, in normalised
  /// coordinates of the displayed image.
  ///
  /// `nil` when the buffer carries no orientation. Falling back to identity would silently
  /// produce plausible-but-wrong positions, and no indicator beats a misplaced one.
  public func displayPoint(for pointOfInterest: Point) -> Point? {
    guard orientation != nil else {
      return nil
    }
    return orientationTransform.applyAboutUnitCentre(to: pointOfInterest)
  }

  /// The point of interest to send for a normalised position on the view finder.
  ///
  /// Clamped to the image, so a drag that runs off the edge pins to the border rather than
  /// being rejected by the device as out of bounds.
  public func pointOfInterest(for displayPoint: Point) -> Point? {
    guard orientation != nil else {
      return nil
    }
    let point = orientationTransform.inverted.applyAboutUnitCentre(to: displayPoint)
    return Point(x: point.x.clampedToUnit, y: point.y.clampedToUnit)
  }
}

extension Double {
  fileprivate var clampedToUnit: Double {
    min(max(self, 0), 1)
  }
}
