public protocol CameraHubAdvertiserFactoryPort: Sendable {
    func createHubAdvertiser(with hubDescriptor: CameraHubDescriptor) async
        -> any CameraHubAdvertisingServicePort
}
