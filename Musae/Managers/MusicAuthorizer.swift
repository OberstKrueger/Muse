import Combine
import MediaPlayer

/// Checks and requests authorization status for the user's music library.
class MusicAuthorizer: ObservableObject {
    /// The current authorization status of the user's music library.
    @Published var status: MusicAuthorizationStatus = .unknown

    /// Requests authorization from the user.
    func requestAuthorization() {
        MPMediaLibrary.requestAuthorization({ _ in
            DispatchQueue.main.async {
                self.updateStatus()
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

    init() {
        updateStatus()
    }

    // Used for UI-building purposes.
    init(status: MusicAuthorizationStatus) {
        self.status = status
    }
}

/// Authorization status of the user's music library.
enum MusicAuthorizationStatus {
    /// Library access is authorized.
    case authorized
    /// Library access is denied.
    case denied
    /// Library access has not been asked for yet.
    case notAsked
    /// Library access is unknown; initialization state.
    case unknown
}
