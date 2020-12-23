import Combine
import Foundation

/// User settings.
class MusicSettings: ObservableObject {
    @Published var _upNextMinutes: UInt = 1
    @Published var _sortByAveragePlayCount: Bool = false

    /// The user defaults database.
    let defaults = UserDefaults.standard

    /// Sort playlist view by average playcount instead of alphabetically.
    var sortByAveragePlayCount: Bool {
        get { return _sortByAveragePlayCount }
        set {
            _sortByAveragePlayCount = newValue

            defaults.set(newValue, forKey: UserDefaultsStrings.sortByAveragePlayCount.rawValue)
        }
    }

    /// Number of minutes for Up Next play.
    var upNextMinutes: UInt {
        get { return _upNextMinutes }
        set {
            switch newValue {
            case 0:       _upNextMinutes = 1
            case 1...480: _upNextMinutes = newValue
            default:      _upNextMinutes = 480
            }

            defaults.set(Int(newValue), forKey: UserDefaultsStrings.upNextMinutes.rawValue)
        }
    }

    init() {
        let checkUpNextMinutes = defaults.integer(forKey: UserDefaultsStrings.upNextMinutes.rawValue)

        sortByAveragePlayCount = defaults.bool(forKey: UserDefaultsStrings.sortByAveragePlayCount.rawValue)
        upNextMinutes = checkUpNextMinutes > 0 ? UInt(checkUpNextMinutes) : 30
    }
}

enum UserDefaultsStrings: String {
    case sortByAveragePlayCount = "SortByAveragePlayCount"
    case upNextMinutes = "UpNextMinutes"
}
