import GameplayKit
import MediaPlayer
import os

class AuthorizationCheckingState: GKState {
    init(logger: Logger) {
        self.logger = logger

        super.init()
    }

    let logger: Logger

    override func didEnter(from previousState: GKState?) {
        logger.info("Entering checking state.")

        switch MPMediaLibrary.authorizationStatus() {
        case .authorized, .denied, .restricted: self.stateMachine?.enter(AuthorizationKnownState.self)
        case .notDetermined: self.stateMachine?.enter(AuthorizationUnknownState.self)

        @unknown default:
            fatalError("Unknown MPMediaLibrary.authorizationStatus() returned: \(MPMediaLibrary.authorizationStatus())")
        }
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == AuthorizationKnownState.self || stateClass == AuthorizationUnknownState.self
    }
}
