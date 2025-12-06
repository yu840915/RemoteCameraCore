import Combine

public protocol EventServiceClientPort: Sendable {
  associatedtype Event: Sendable
  associatedtype Command: Sendable

  var onStatus: AnyPublisher<NodeStatus, Never> { get }

  var onCommand: AnyPublisher<Command, Never> { get }
  var onError: AnyPublisher<Error, Never> { get }
  func notify(_ event: Event) async
  func report(_ error: Error) async
  func unbind(_ error: Error?) async
}

public protocol StateServiceClientPort: EventServiceClientPort {
  associatedtype State: Sendable

  func update(_ state: State) async
}
