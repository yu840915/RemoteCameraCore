public enum FocusMode: Sendable, CustomStringConvertible {
  case locked
  case auto

  public var description: String {
    switch self {
    case .locked: return "locked"
    case .auto: return "auto"
    }
  }
}

public enum ExposureMode: Sendable, CustomStringConvertible {
  case locked
  case auto

  public var description: String {
    switch self {
    case .locked: return "locked"
    case .auto: return "auto"
    }
  }
}

public enum WhiteBalanceMode: Sendable, CustomStringConvertible {
  case locked
  case auto

  public var description: String {
    switch self {
    case .locked: return "locked"
    case .auto: return "auto"
    }
  }
}

public struct Point: Sendable, Equatable, CustomStringConvertible {
  public var x: Double
  public var y: Double
  public init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }

  public var description: String {
    return "(x: \(x), y: \(y))"
  }
}

public enum TorchMode: Sendable, CustomStringConvertible {
  case on
  case off
  case auto

  public var description: String {
    switch self {
    case .on: return "on"
    case .off: return "off"
    case .auto: return "auto"
    }
  }
}

public enum FlashMode: Sendable, CustomStringConvertible {
  case on
  case off
  case auto

  public var description: String {
    switch self {
    case .on: return "on"
    case .off: return "off"
    case .auto: return "auto"
    }
  }
}

public struct TemperatureAndTint: Sendable, Equatable, CustomStringConvertible {
  public var temperature: Double
  public var tint: Double
  public init(temperature: Double, tint: Double) {
    self.temperature = temperature
    self.tint = tint
  }

  public var description: String {
    return "WB(temperature: \(temperature), tint: \(tint))"
  }
}

public struct WhiteBalanceGains: Sendable, Equatable, CustomStringConvertible {
  public var redGain: Double
  public var greenGain: Double
  public var blueGain: Double
  public init(redGain: Double, greenGain: Double, blueGain: Double) {
    self.redGain = redGain
    self.greenGain = greenGain
    self.blueGain = blueGain
  }

  public var description: String {
    return "WBGains(R: \(redGain), G: \(greenGain), B: \(blueGain))"
  }
}
