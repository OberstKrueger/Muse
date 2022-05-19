import Foundation
import os

/// Daily playlists for the library.
struct DailyPlaylists {
    // MARK: - Initializations
    init() {}

    init(_ categories: [Category]) {
        let defaults = Defaults()

        if Calendar.current.isDateInToday(defaults.dailyDate) == false {
            for category in categories {
                var selection: Int {
                    let check: Int = category.playlists.count / 2

                    switch check {
                    case ...0: return 0
                    default:
                        var result: Int = 1
                        for _ in 1..<(64 - check.leadingZeroBitCount) {
                            result *= 2
                        }
                        return result - 1
                    }
                }

                if category.unplayedPlaylists.count > 0 {
                    let mostUnplayed = category.unplayedPlaylists.sorted(by: {$0.unplayed > $1.unplayed})[0]

                    logger.info("Daily playlist for \(category.title): \(mostUnplayed.title) has most unplayed.")
                    playlists[category.title] = mostUnplayed
                } else {
                    let normalPlaylist = category.playlists
                        .filter({$0.averagePlayCount.isNormal})
                        .sorted(by: {$0.averagePlayCount < $1.averagePlayCount})[...selection]
                        .randomElement()!

                    playlists[category.title] = normalPlaylist
                }
            }

            date = Date()

            defaults.dailyDate = date
            defaults.dailyPlaylists = Dictionary(uniqueKeysWithValues: playlists.map({($0.key, $0.value.id)}))
        } else {
            date = defaults.dailyDate
            for category in categories {
                if let id = defaults.dailyPlaylists[category.title] {
                    for playlist in category.combinedPlaylists where playlist.id == id {
                        playlists[category.title] = playlist
                        break   // This shouldn't be an issue, as playlists will not share IDs.
                    }
                }
            }
        }
    }

    /// Date dailiy playlists were updated.
    var date: Date = Date(timeIntervalSince1970: 0)

    /// Daily playlists by category.
    var playlists: [String: Playlist] = [:]

    /// System logger.
    private let logger = Logger(subsystem: "technology.krueger.musae", category: "daily")
}
