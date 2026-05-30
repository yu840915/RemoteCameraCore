extension Duration {
  public init(_ double: Double) {
    precondition(double.isFinite, "Duration must be finite")
    let attoSecPerSec: Int64 = 1_000_000_000_000_000_000
    var sec = Int64(double.rounded(.towardZero))
    var attosec = Int64((double - Double(sec)) * Double(attoSecPerSec))
    if attosec >= attoSecPerSec || attosec <= -attoSecPerSec {
      let extraSec = attosec / attoSecPerSec
      let (newSec, overflow) = sec.addingReportingOverflow(extraSec)
      precondition(!overflow, "Duration overflow")
      sec = newSec
      attosec -= extraSec * attoSecPerSec
    }

    self.init(
      secondsComponent: sec,
      attosecondsComponent: attosec
    )
  }

  public var doubleValue: Double {
    Double(components.seconds) + Double(components.attoseconds) / 1_000_000_000_000_000_000
  }
}
