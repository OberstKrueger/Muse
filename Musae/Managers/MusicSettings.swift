import Combine

/// User settings.
class MusicSettings: ObservableObject {
    /// Number of minutes for Up Next play.
    @Published var upNextMinutes: UInt = 32
}
