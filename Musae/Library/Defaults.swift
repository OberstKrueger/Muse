import Foundation

/// Values stored in UserDefaults.
class Defaults {
    let defaults = UserDefaults.standard

    var sortByAveragePlayCount: Bool {
        get { return defaults.bool(forKey: DefaultsStrings.sortByAveragePlayCount.rawValue) }
        set { defaults.set(newValue, forKey: DefaultsStrings.sortByAveragePlayCount.rawValue) }
    }

    var upNextMinutes: UInt {
        get { return UInt(bitPattern: defaults.integer(forKey: DefaultsStrings.upNextMinutes.rawValue)) }
        set { defaults.set(Int(bitPattern: newValue), forKey: DefaultsStrings.upNextMinutes.rawValue) }
    }
}

fileprivate enum DefaultsStrings: String {
    case sortByAveragePlayCount = "SortByAveragePlayCount"
    case upNextMinutes = "UpNextMinutes"
}
