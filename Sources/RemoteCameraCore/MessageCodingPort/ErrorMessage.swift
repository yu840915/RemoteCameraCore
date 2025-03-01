struct ErrorMessage: Error {
  let domain: String
  let code: Int
  let message: String?
}

protocol ErrorMessageConvertible: Error {
  var toErrorMessage: ErrorMessage { get }
}
