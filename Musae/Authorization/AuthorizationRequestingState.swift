import GameplayKit
import MediaPlayer
import os

class AuthorizationRequestingState: GKState {
    init(logger: Logger) {
        self.logger = logger

        super.init()
    }

    let logger: Logger

    override func didEnter(from previousState: GKState?) {
        logger.info("Entering requesting state.")

        MPMediaLibrary.requestAuthorization({ _ in
            self.stateMachine?.enter(AuthorizationCheckingState.self)
        })
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == AuthorizationCheckingState.self
    }
}
