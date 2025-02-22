import Combine

public protocol EventServiceClientPort: Sendable {
  associatedtype Event: Sendable
  associatedtype Command: Sendable

  func notify(_ event: Event) async
  func onError(_ error: Error) async
  var onCommand: any Publisher<Command, any Error> { get }
  func unbind(_ error: Error?) async
}

public protocol StateServiceClientPort: EventServiceClientPort {
  associatedtype State: Sendable

  func update(_ state: State) async
}
