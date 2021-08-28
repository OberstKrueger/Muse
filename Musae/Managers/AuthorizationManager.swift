import MediaPlayer
import SwiftUI

/// Checks and requests authorization status for the user's music library.
class AuthorizationManager: ObservableObject {
    // MARK: - Initializations
    init() {
        self.status = .unknown
        self.updateStatus()
    }

    init(status: LibraryAuthorizationStatus = .unknown) {
        self.status = status
    }
    
    // MARK: - Public Properties
    /// The current authorization status of the user's music library.
    @Published var status: LibraryAuthorizationStatus

    // MARK: - Public Functions
    /// Requests authorization from the user.
    func requestAuthorization() {
        MPMediaLibrary.requestAuthorization({ _ in
            if Thread.isMainThread {
                self.updateStatus()
            } else {
                DispatchQueue.main.async {
                    self.updateStatus()
                }
            }
        })
    }

    /// Updates current authorization status.
    func updateStatus() {
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
