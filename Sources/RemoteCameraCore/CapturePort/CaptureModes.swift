public enum CaptureMode: Sendable, Equatable {
  // Monitor is the default view only mode, void of capture capabilities.
  case monitor
  case photo
  case video
  case audio
  case timelapse
}

extension CaptureMode {
  public struct FeatureTable: Sendable, Equatable {
    public var photo = false
    public var video = false
    public var audio = false
    public var timelapse = false

    public init() {}
  }
}

extension CaptureMode: CustomStringConvertible {
  public var description: String {
    switch self {
    case .monitor: "Monitor"
    case .photo: "Photo"
    case .video: "Video"
    case .audio: "Audio"
    case .timelapse: "TimeLapse"
    }
  }
}

extension CaptureMode.FeatureTable: CustomStringConvertible {
  public var description: String {
    var modes = [String]()
    if photo { modes.append("Photo") }
    if video { modes.append("Video") }
    if audio { modes.append("Audio") }
    if timelapse { modes.append("Time-Lapse") }
    return "Available Modes: \(modes.joined(separator: ", "))"
  }
}
