import GameplayKit
import MediaPlayer
import os

class AuthorizationKnownState: GKState {
    init(logger: Logger) {
        self.logger = logger

        super.init()
    }

    let logger: Logger

    var status: AuthorizationStatus {
        switch MPMediaLibrary.authorizationStatus() {
        case .authorized,
             .restricted:    return .authorized
        case .denied:        return .denied
        case .notDetermined: return .unknown
        @unknown default:
            fatalError("Unknown MPMediaLibrary.authorizationStatus() returned: \(MPMediaLibrary.authorizationStatus())")
        }
    }

    var timer: Timer?

    override func didEnter(from previousState: GKState?) {
        logger.info("Entering known state.")

        if let authMachine = self.stateMachine as? AuthorizationMachine {
            DispatchQueue.main.async {
                authMachine.status = self.status
            }
        }

        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { _ in
            self.stateMachine?.enter(AuthorizationCheckingState.self)
        }
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == AuthorizationCheckingState.self
    }

    override func willExit(to nextState: GKState) {
        timer?.invalidate()
        timer = nil
    }
}
