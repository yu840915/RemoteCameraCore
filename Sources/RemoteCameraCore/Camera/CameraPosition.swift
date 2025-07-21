public enum CameraPosition: Sendable, CustomStringConvertible {
  case external
  case builtInFront
  case builtInBack

  public var description: String {
    switch self {
    case .external: return "external"
    case .builtInFront: return "front"
    case .builtInBack: return "back"
    }
  }
}
