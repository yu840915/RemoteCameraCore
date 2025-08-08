public enum NodeStatus: Sendable, Equatable {
  public static func == (lhs: NodeStatus, rhs: NodeStatus) -> Bool {
    switch (lhs, rhs) {
    case (.preparing, .preparing), (.ready, .ready), (.cancelled(nil), .cancelled(nil)):
      return true
    default:
      return false
    }
  }

  case preparing
  case ready
  case cancelled(Error?)
}

struct NodeStatusMerger {
  func merge(_ statuses: [NodeStatus]) -> NodeStatus {
    statuses.first {
      if case .cancelled = $0 { true } else { false }
    } ?? statuses.first {
      if case .preparing = $0 { true } else { false }
    }
      ?? .ready
  }
}
