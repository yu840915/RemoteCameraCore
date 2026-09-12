extension CaptureServiceState {
  public func diff(
    from previous: CaptureServiceState
  ) -> [CaptureServiceStateUpdateMessage] {
    var messages = [CaptureServiceStateUpdateMessage]()
    if capabilities != previous.capabilities {
      messages.append(.capabilities(capabilities))
    }
    if availableModes != previous.availableModes {
      messages.append(.availableModes(availableModes))
    }
    if availableCommands != previous.availableCommands {
      messages.append(.availableCommands(availableCommands))
    }
    if availableConfigurationCommands != previous.availableConfigurationCommands {
      messages.append(
        .availableConfigurationCommands(availableConfigurationCommands)
      )
    }
    if configuration != previous.configuration {
      messages.append(.configuration(configuration))
    }
    if let camera = camera, camera != previous.camera {
      messages.append(.cameraDescriptor(camera))
    }
    if microphones != previous.microphones {
      messages.append(.microphoneDescriptors(microphones))
    }
    if captureTasks != previous.captureTasks {
      messages.append(.captureTasks(captureTasks))
    }
    if recordingTasks != previous.recordingTasks {
      messages.append(.recordingTasks(recordingTasks))
    }
    if mode != previous.mode {
      messages.append(.mode(mode))
    }
    return messages
  }
}
