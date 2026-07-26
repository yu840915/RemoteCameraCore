public struct MediaFileInfo: Sendable, Equatable {
  public let fileID: String
  public let fileName: String
  public let byteCount: UInt64
  public let contentType: String
  public let createdAt: Timestamp

  public init(
    fileID: String,
    fileName: String,
    byteCount: UInt64,
    contentType: String,
    createdAt: Timestamp
  ) {
    self.fileID = fileID
    self.fileName = fileName
    self.byteCount = byteCount
    self.contentType = contentType
    self.createdAt = createdAt
  }
}

extension MediaFileInfo: CustomStringConvertible {
  public var description: String {
    "MediaFileInfo(id: \(fileID), name: \(fileName), size: \(byteCount) bytes, type: \(contentType))"
  }
}
