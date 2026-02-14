import Foundation

/// Values stored in UserDefaults.
class DefaultsService {
    private let defaults: UserDefaults

    init() {
        defaults = .standard

        #if DEBUG
        defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier ?? "technology.krueger.muse")
        #endif
    }

    /// Retrieves the daily playlists from UserDefaults.
    /// - Returns: A dictionary that contains the playlist name and persistent ID.
    func fetchDailyPlaylists() -> [String: UInt64] {
        return defaults.dictionary(forKey: DefaultsStrings.dailyPlaylists.rawValue) as? [String: UInt64] ?? [:]
    }
    
    /// Retrieves the date the daily playlists were last calculated.
    /// - Returns: A date or the default UNIX time if a date is not stored.
    func fetchDailyDate() -> Date {
        (defaults.object(forKey: DefaultsStrings.dailyDate.rawValue) as? Date) ?? Date(timeIntervalSince1970: 0)
    }
    
    /// Saves a dictionary of current daily playlists.
    /// - Parameter playlists: A dictionary of genres and playlist persistent IDs.
    func setDailyPlaylists(_ playlists: [String: UInt64]) {
        defaults.set(playlists, forKey: DefaultsStrings.dailyPlaylists.rawValue)
    }
    
    /// Saves the current date for daily playlists.
    /// - Parameter date: The date.
    func setDailyDate(_ date: Date) {
        defaults.set(date, forKey: DefaultsStrings.dailyDate.rawValue)
    }
}

/// String values from UserDefault keys.
private enum DefaultsStrings: String {
    case dailyDate = "dailyDate"
    case dailyPlaylists = "dailyPlaylists"
}
