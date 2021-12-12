import SwiftUI

/// User settings.
class MusicSettings: ObservableObject {
    // MARK: - Initializations
    init() {
        sortByAveragePlayCount = defaults.sortByAveragePlayCount
        upNextMinutes = defaults.upNextMinutes
    }

    // MARK: - Private Properties
    /// The user defaults database.
    let defaults = Defaults()

    /// Internal storage value for sortByAveragePlayCount
    @Published var sortByAveragePlayCountInternal: Bool = false

    /// Internal storage value for upNextMinutes
    @Published var upNextMinutesInternal: Int = 1

    // MARK: - Public Properties
    /// Sort playlist view by average playcount instead of alphabetically.
    var sortByAveragePlayCount: Bool {
        get { return sortByAveragePlayCountInternal }
        set {
            defaults.sortByAveragePlayCount = newValue
            sortByAveragePlayCountInternal = newValue
        }
    }

    /// Number of minutes for Up Next play.
    var upNextMinutes: Int {
        get { return upNextMinutesInternal }
        set {
            switch newValue {
            case ...0:       upNextMinutesInternal = 1
            case 1...480: upNextMinutesInternal = newValue
            default:      upNextMinutesInternal = 480
            }

            defaults.upNextMinutes = newValue
        }
    }
}
