public protocol CameraHubAdvertiserFactoryPort: Sendable {
    func createHubAdvertiser(with hubDescriptor: CameraHubDescriptor)
        -> any CameraHubAdvertisingServicePort
}
