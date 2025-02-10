public protocol CameraHubAdvertiserFactoryPort {
    func createHubAdvertiser(with hubDescriptor: CameraHubDescriptor)
        -> any CameraHubAdvertisingServicePort
}
