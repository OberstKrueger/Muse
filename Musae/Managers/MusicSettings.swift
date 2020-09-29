import Combine

/// User settings.
class MusicSettings: ObservableObject {
    /// Sort playlist view by average playcount instead of alphabetically.
    @Published var sortByAveragePlayCount: Bool = true
    /// Number of minutes for Up Next play.
    @Published var upNextMinutes: UInt = 32
}
