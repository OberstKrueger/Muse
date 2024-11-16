import Foundation

/// Values stored in UserDefaults.
actor DefaultsService {
    private let defaults: UserDefaults

    init() {
        defaults = .standard

        #if DEBUG
        defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        #endif
    }


    /// Retrieves the daily playlists from UserDefaults.
    /// - Returns: A dictionary that contains the playlist name and persistent ID.
    func fetchDailyPlaylists() async -> [String: UInt64] {
        return defaults.dictionary(forKey: DefaultsStrings.dailyPlaylists.rawValue) as? [String: UInt64] ?? [:]
    }
    
    /// Retrieves the date the daily playlists were last calculated.
    /// - Returns: A date or the default UNIX time if a date is not stored.
    func fetchDailyDate() async -> Date {
        let seconds: TimeInterval = defaults.double(forKey: DefaultsStrings.dailyDate.rawValue)

        switch seconds {
        case 0: return Date(timeIntervalSince1970: 0)
        default: return Date(timeIntervalSince1970: seconds)
        }
    }
    
    /// Saves a dictionary of current daily playlists.
    /// - Parameter playlists: A dictionary of genres and playlist persistent IDs.
    func setDailyPlaylists(_ playlists: [String: UInt64]) async {
        defaults.set(playlists, forKey: DefaultsStrings.dailyPlaylists.rawValue)
    }
    
    /// Saves the current date for daily playlists.
    /// - Parameter date: The date.
    func setDailyDate(_ date: Date) async {
        defaults.set(date.timeIntervalSince1970, forKey: DefaultsStrings.dailyDate.rawValue)
    }
}

/// String values from UserDefault keys.
fileprivate enum DefaultsStrings: String {
    case dailyDate = "dailyDate"
    case dailyPlaylists = "dailyPlaylists"
}
