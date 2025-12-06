@preconcurrency import Combine

public protocol EventServicePort: Sendable {
  associatedtype Event: Sendable
  associatedtype Command: Sendable

  var onStatus: AnyPublisher<NodeStatus, Never> { get }

  var onEvent: AnyPublisher<Event, Never> { get }
  var onError: AnyPublisher<Error, Never> { get }
  func perform(_ command: Command) async throws
}

public protocol StateServicePort: EventServicePort {
  associatedtype State: Sendable

  var state: State { get }
  var onState: AnyPublisher<State, Never> { get }
}
