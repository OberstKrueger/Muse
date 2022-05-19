import MediaPlayer
import SwiftUI
import os

/// Checks and requests authorization status for the user's music library.
class AuthorizationManager: ObservableObject {
    init() {
        logger.info("Authorization status unknown.")

        self.status = .unknown
        self.updateStatus()
    }

    init(status: AuthorizationStatus = .unknown) {
        self.status = status
    }

    /// The current authorization status of the user's music library.
    @Published var status: AuthorizationStatus

    private var logger = Logger(subsystem: "technology.krueger.musae", category: "authorization")

    /// Requests authorization from the user.
    func requestAuthorization() {
        logger.info("Requesting authorization.")

        MPMediaLibrary.requestAuthorization({ _ in
            self.updateStatus()
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
