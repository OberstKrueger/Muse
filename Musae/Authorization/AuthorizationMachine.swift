import GameplayKit
import MediaPlayer
import SwiftUI
import os

class AuthorizationMachine: GKStateMachine, ObservableObject {
    init() {
        logger = Logger(subsystem: "technology.krueger.musae", category: "authorization")

        logger.info("Initializing authorization state machine.")

        let checking   = AuthorizationCheckingState(logger: logger)
        let known      = AuthorizationKnownState(logger: logger)
        let requesting = AuthorizationRequestingState(logger: logger)
        let unknown    = AuthorizationUnknownState(logger: logger)

        super.init(states: [checking, known, requesting, unknown])

        let _ = self.enter(AuthorizationCheckingState.self)
    }

    fileprivate let logger: Logger

    /// Current authorization status. Does not require knowledge of current state.
    @Published var status: AuthorizationStatus = .initializing {
        didSet {
            switch status {
            case .authorized:   logger.info("Status: authorized")
            case .denied:       logger.info("Status: denied")
            case .initializing: logger.info("Status: initializing")
            case .unknown:      logger.info("Status: unknown")
            }
        }
    }
}
