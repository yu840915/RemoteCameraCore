public enum FocusMode: Sendable {
  case locked
  case auto
}

public enum ExposureMode: Sendable {
  case locked
  case auto
}

public enum WhiteBalanceMode: Sendable {
  case locked
  case auto
}

public struct Point: Sendable, Equatable {
  public var x: Double
  public var y: Double
  public init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }
}

public enum TorchMode: Sendable {
  case on
  case off
  case auto
}

public enum FlashMode: Sendable {
  case on
  case off
  case auto
}

public struct TemperatureAndTint: Sendable, Equatable {
  public var temperature: Double
  public var tint: Double
  public init(temperature: Double, tint: Double) {
    self.temperature = temperature
    self.tint = tint
  }
}

public struct WhiteBalanceGains: Sendable, Equatable {
  public var redGain: Double
  public var greenGain: Double
  public var blueGain: Double
  public init(redGain: Double, greenGain: Double, blueGain: Double) {
    self.redGain = redGain
    self.greenGain = greenGain
    self.blueGain = blueGain
  }
}
