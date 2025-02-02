import Combine

public enum BindingError: Error {
  case eventPublisherClosedUnexpectedly
  case statePublisherClosedUnexpectedly
}

public
  actor EventServiceClientBinding<Service: EventServicePort, Client: EventServiceClientPort>
where Service.Command == Client.Command, Service.Event == Client.Event {
  private let service: Service
  private let client: Client
  private nonisolated(unsafe) var bag = Set<AnyCancellable>()

  public init(client: Client, service: Service) {
    self.client = client
    self.service = service
    client.onCommand.sink { [weak self] command in
      Task { [weak self] in
        await self?.routeCommand(command)
      }
    }.store(in: &bag)
    service.onEvent.sink { [weak self] completion in
      Task { [weak self] in
        await self?.handleHubEventCompletion(completion)
      }
    } receiveValue: { [weak self] event in
      Task { [weak self] in
        await self?.routeEvent(event)
      }
    }.store(in: &bag)
  }

}

extension EventServiceClientBinding {
  func routeCommand(_ command: Client.Command) async {
    do {
      try await service.perform(command)
    } catch {
      await client.onError(error)
    }
  }

  func routeEvent(_ event: Service.Event) async {
    await client.notify(event)
  }

  func handleHubEventCompletion(_ completion: Subscribers.Completion<Error>) async {
    switch completion {
    case .finished:
      await client.onError(BindingError.eventPublisherClosedUnexpectedly)
    case .failure(let error):
      await client.onError(error)
    }
  }
}

public
  actor StateServiceClientBinding<Service: StateServicePort, Client: StateServiceClientPort>
where
  Service.Command == Client.Command, Service.Event == Client.Event, Service.State == Client.State
{
  private let service: Service
  private let client: Client
  private let eventBinding: EventServiceClientBinding<Service, Client>
  private nonisolated(unsafe) var bag = Set<AnyCancellable>()

  public init(client: Client, service: Service) {
    self.client = client
    self.service = service
    eventBinding = EventServiceClientBinding(client: client, service: service)
    service.onState.sink { [weak self] completion in
      Task { [weak self] in
        await self?.handleHubStateCompletion(completion)
      }
    } receiveValue: { [weak self] state in
      Task { [weak self] in
        await self?.updateState(state)
      }
    }.store(in: &bag)
  }
}

extension StateServiceClientBinding {
  func updateState(_ update: Service.State) async {
    await client.update(update)
  }

  func handleHubStateCompletion(_ completion: Subscribers.Completion<Error>) async {
    switch completion {
    case .finished:
      await client.onError(BindingError.statePublisherClosedUnexpectedly)
    case .failure(let error):
      await client.onError(error)
    }
  }
}
