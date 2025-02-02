protocol CommandAvailabilityChecking: Sendable {
  associatedtype Command: Sendable

  func canPerform(_ command: Command) -> Bool
}
