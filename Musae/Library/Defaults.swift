import Foundation

/// Values stored in UserDefaults.
class Defaults {
    init() {
        defaults = .standard

        #if DEBUG
        defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        #endif
    }

    private let defaults: UserDefaults

    /// The last daily playlists saved.
    var dailyPlaylists: [String: UInt64] {
        get {
            switch defaults.dictionary(forKey: DefaultsStrings.dailyPlaylists.rawValue) as? [String: UInt64] {
            case .none: return [:]
            case .some(let playlists): return playlists
            }

        }
        set { defaults.set(newValue, forKey: DefaultsStrings.dailyPlaylists.rawValue) }
    }

    /// The date the daily playlists were last saved.
    var dailyDate: Date {
        get {
            let seconds: TimeInterval = defaults.double(forKey: DefaultsStrings.dailyDate.rawValue)

            switch seconds {
            case 0: return Date(timeIntervalSince1970: 0)
            default: return Date(timeIntervalSince1970: seconds)
            }
        }
        set { defaults.set(newValue.timeIntervalSince1970, forKey: DefaultsStrings.dailyDate.rawValue) }
    }
}

/// String values from UserDefault keys.
private enum DefaultsStrings: String {
    case dailyDate = "dailyDate"
    case dailyPlaylists = "dailyPlaylists"
    case sortByAveragePlayCount = "SortByAveragePlayCount"
    case upNextMinutes = "UpNextMinutes"
}
