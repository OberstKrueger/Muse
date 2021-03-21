import Foundation

/// Values stored in UserDefaults.
class Defaults {
    // MARK: - Internal Properties
    let defaults = UserDefaults.standard

    // MARK: - Public Properties
    var dailyPlaylists: [String: String] {
        get {
            switch defaults.dictionary(forKey: DefaultsStrings.dailyPlaylists.rawValue) as? [String: String] {
            case .none: return [:]
            case .some(let playlists): return playlists
            }

        }
        set { defaults.set(newValue, forKey: DefaultsStrings.dailyPlaylists.rawValue) }
    }

    // MARK: - Public Functiones
    var dailyDate: Date? {
        get {
            let seconds: TimeInterval = defaults.double(forKey: DefaultsStrings.dailyDate.rawValue)

            switch seconds {
            case 0: return nil
            default: return Date(timeIntervalSince1970: seconds)
            }
        }
        set { defaults.set(newValue?.timeIntervalSince1970 ?? 0, forKey: DefaultsStrings.dailyDate.rawValue) }
    }

    var sortByAveragePlayCount: Bool {
        get { return defaults.bool(forKey: DefaultsStrings.sortByAveragePlayCount.rawValue) }
        set { defaults.set(newValue, forKey: DefaultsStrings.sortByAveragePlayCount.rawValue) }
    }

    var upNextMinutes: Int {
        get { return defaults.integer(forKey: DefaultsStrings.upNextMinutes.rawValue) }
        set { defaults.set(newValue, forKey: DefaultsStrings.upNextMinutes.rawValue) }
    }
}

/// String values from UserDefault keys.
fileprivate enum DefaultsStrings: String {
    case dailyDate = "dailyDate"
    case dailyPlaylists = "dailyPlaylists"
    case sortByAveragePlayCount = "SortByAveragePlayCount"
    case upNextMinutes = "UpNextMinutes"
}
