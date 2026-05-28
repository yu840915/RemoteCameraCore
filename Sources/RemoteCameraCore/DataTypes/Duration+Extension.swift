extension Duration {
  public init(_ double: Double) {
    self.init(
      secondsComponent: Int64(double),
      attosecondsComponent: Int64((double - Double(Int64(double))) * 1_000_000_000_000_000_000))
  }

  public var doubleValue: Double {
    Double(components.seconds) + Double(components.attoseconds) / 1_000_000_000_000_000_000
  }
}
