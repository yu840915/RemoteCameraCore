public protocol ConnectionArgumentProviding: Sendable, Equatable {}

extension ConnectionArgumentProviding {
  func isEqual(to other: any ConnectionArgumentProviding) -> Bool {
    guard let other = other as? Self else {
      return false
    }
    return self == other
  }
}

public struct ConnectionSuite: Sendable, Equatable {
  public static func == (lhs: ConnectionSuite, rhs: ConnectionSuite) -> Bool {
    lhs.id == rhs.id
      && lhs.arguments.isEqual(to: rhs.arguments)
  }

  public let id: String
  public let arguments: any ConnectionArgumentProviding

  public init(
    id: String,
    arguments: any ConnectionArgumentProviding
  ) {
    self.id = id
    self.arguments = arguments
  }
}

extension ConnectionSuite: CustomStringConvertible {
  public var description: String {
    "ConnectionSuite(id: \(id), arguments: \(arguments))"
  }
}

