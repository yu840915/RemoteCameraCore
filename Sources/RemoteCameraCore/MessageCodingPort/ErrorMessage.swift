public struct ErrorMessage: Error, Equatable {
  public let domain: String
  public let code: Int
  public let message: String?

  public init(domain: String, code: Int, message: String? = nil) {
    self.domain = domain
    self.code = code
    self.message = message
  }
}

protocol ErrorMessageConvertible: Error {
  var toErrorMessage: ErrorMessage { get }
}

public struct ErrorMessageCoders {
  public typealias ErrorEncoder<Data> = MessageEncodingServicePort<
    ErrorMessage, Data
  >
  public typealias ErrorDecoder<Data> = MessageDecodingServicePort<
    Data, ErrorMessage
  >
}
