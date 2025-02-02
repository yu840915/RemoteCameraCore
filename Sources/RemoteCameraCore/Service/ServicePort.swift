import Combine

public protocol EventServicePort: Sendable {
  associatedtype Event: Sendable
  associatedtype Command: Sendable

  var onEvent: any Publisher<Event, Error> { get }
  func perform(_ command: Command) async throws
}

public protocol StateServicePort: EventServicePort {
  associatedtype State: Sendable

  var state: State { get }
  var onState: any Publisher<State, Error> { get }
}
