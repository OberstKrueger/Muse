import MediaPlayer
import os

/// Checks and requests authorization status for the user's music library.
@Observable
class AuthorizationManager {
    init() {
        self.status = .unknown
        self.updateStatus()

        logger.info("Authorization status unknown.")
    }

    init(status: AuthorizationStatus = .unknown) {
        self.status = status
    }

    /// The current authorization status of the user's music library.
    var status: AuthorizationStatus

    private var logger = Logger(subsystem: "technology.krueger.muse", category: "authorization")

    /// Requests authorization from the user.
    func requestAuthorization() {
        logger.info("Requesting authorization.")

        MPMediaLibrary.requestAuthorization({ _ in
            Task { @MainActor in
                self.updateStatus()
            }
        })
    }

    /// Updates current authorization status.
    func updateStatus() {
        logger.info("Updating authorization status.")

        switch MPMediaLibrary.authorizationStatus() {
        case .authorized,
             .restricted:    status = .authorized
        case .denied:        status = .denied
        case .notDetermined: status = .notAsked
        @unknown default:
            fatalError("Unknown MPMediaLibrary.authorizationStatus() returned: \(MPMediaLibrary.authorizationStatus())")
        }
    }
}
