import Foundation

/// Daily playlists for the library.
struct DailyPlaylists {
    // MARK: - Initializations
    init() {
        let defaults = Defaults()

        date = defaults.dailyDate
        playlists = defaults.dailyPlaylists
    }

    init(_ libraryPlaylists: [String: [MusicPlaylist]]) {
        let defaults = Defaults()

        for (key, value) in libraryPlaylists {
            var selection: Int {
                let check: Int = value.count / 2

                switch check {
                case ...0: return 0
                default:
                    var result: Int = 1
                    for _ in 1..<(64 - check.leadingZeroBitCount) {
                        result *= 2
                    }
                    return result
                }
            }

            let sorted: [String] = value.filter({$0.averagePlayCount.isNaN == false})
                .sorted(by: {$0.averagePlayCount < $1.averagePlayCount})
                .map({$0.title})

            playlists[key] = sorted[...selection].randomElement()!
        }

        date = Date()

        defaults.dailyDate = date
        defaults.dailyPlaylists = playlists
    }

    // MARK: - Public Properties
    /// Date dailiy playlists were updated.
    var date: Date?

    /// Daily playlists by category.
    var playlists: [String: String] = [:]
}
