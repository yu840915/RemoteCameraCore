protocol CommandAvailabilityChecking: Sendable, Equatable {
  associatedtype Command: Sendable

  func canPerform(_ command: Command) -> Bool
}
