import Foundation
import os

/// Daily playlists for the library.
struct DailyPlaylists {
    // MARK: - Initializations
    init() {}

    init(_ libraryPlaylists: [String: [Playlist]]) {
        let defaults = Defaults()

        if Calendar.current.isDateInToday(defaults.dailyDate) == false {
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
                        return result - 1
                    }
                }

                let unplayed: [Playlist] = value.filter({$0.unplayed > 0})
                    .sorted(by: {$0.unplayed > $1.unplayed})

                if unplayed.count > 0 {
                    logger.info("Daily playlist for \(key): \(unplayed[0].title) has most unplayed.")
                    playlists[key] = unplayed[0]
                } else {
                    let sorted: [Playlist] = value.filter({$0.averagePlayCount.isNaN == false})
                        .sorted(by: {$0.averagePlayCount < $1.averagePlayCount})

                    playlists[key] = sorted[...selection].randomElement()!
                }
            }

            date = Date()

            defaults.dailyDate = date
            defaults.dailyPlaylists = Dictionary(uniqueKeysWithValues: playlists.map({($0.key, $0.value.id)}))
        } else {
            date = defaults.dailyDate
            for (key, value) in libraryPlaylists {
                if let id = defaults.dailyPlaylists[key] {
                    for playlist in value where playlist.id == id {
                        playlists[key] = playlist
                        break   // This shouldn't be an issue, as playlists will not share IDs.
                    }
                }
            }
        }
    }

    // MARK: - Internal Properties
    /// System logger.
    fileprivate let logger = Logger(subsystem: "technology.krueger.musae", category: "daily")

    // MARK: - Public Properties
    /// Date dailiy playlists were updated.
    var date: Date = Date(timeIntervalSince1970: 0)

    /// Daily playlists by category.
    var playlists: [String: Playlist] = [:]
}
