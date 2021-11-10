import GameplayKit
import MediaPlayer
import os

class AuthorizationUnknownState: GKState {
    init(logger: Logger) {
        self.logger = logger

        super.init()
    }

    let logger: Logger

    override func didEnter(from previousState: GKState?) {
        logger.info("Entering unknown state.")

        if let authMachine = self.stateMachine as? AuthorizationMachine {
            DispatchQueue.main.async {
                authMachine.status = .unknown
            }
        }
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == AuthorizationRequestingState.self
    }
}
