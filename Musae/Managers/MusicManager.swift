import Combine
import Foundation
import MediaPlayer
import os

/// Library manager. Loads and updates playlists from the users music library.
class MusicManager: ObservableObject {
    // MARK: - Initializations
    init() {
        startTimer()
    }

    // MARK: - Internal Properties
    /// System logger.
    let logger = Logger(subsystem: "technology.krueger.musae", category: "library")

    /// Timer for refreshing the music library.
    var timer: Timer?

    // MARK: - Public Properties
    /// The user's music library.
    @Published var library = MusicLibrary()

    /// Daily playlists by category
    @Published var dailyPlaylists: [String: String] = [:]

    /// Date the daily playlists were last updated.
    @Published var dailyPlaylistDate: Date?

    /// Date the timer will fire again.
    @Published var timerNextFireTime: Date?

    // MARK: - Public Functions
    /// Load and update daily playlists
    func loadDailyPlaylists(force: Bool = false) {
        if dailyPlaylistDate == nil || Calendar.current.isDateInToday(dailyPlaylistDate!) == false || force {
            DispatchQueue.global().async { [self] in
                var results: [String: String] = [:]

                for key in library.playlists.keys {
                    /// Results with an average playcount above or equal to 1.
                    let resultsAll: [String] = library.playlists[key, default: []]
                        .sorted(by: {$0.averagePlayCount < $1.averagePlayCount})
                        .map({($0.title)})
                    /// Results with an average playcount below 1.
                    let resultsBelow: [String] = library.playlists[key, default: []]
                        .filter({$0.averagePlayCount < 1})
                        .map({$0.title})

                    if let playlist = resultsBelow.randomElement() {
                        results[key] = playlist
                    } else {
                        switch resultsAll.count {
                        case ...0: results[key] = "Empty category!"
                        case ...4: results[key] = resultsAll[0]
                        case ...8: results[key] = resultsAll[...3].randomElement()!
                        default:   results[key] = resultsAll[...7].randomElement()!
                        }
                    }
                }

                DispatchQueue.main.async {
                    dailyPlaylists = results
                    dailyPlaylistDate = Date()
                }
            }
        }
    }

    /// Returns the playlist by a name.
    /// - Note: If multiple playlists have the same name, the function will return a combined playlist of their contents.
    func playlistByName(category: String, name: String) -> MusicPlaylist? {
        let results = library.playlists[category, default: []].filter({$0.title == name})

        switch results.count {
        case ...0:
            logger.notice("Playlist \"\(category) - \(name)\" was not found in the library.")

            return nil
        case 1:
            return results[0]
        default:
            var songs: [MPMediaItem] = []

            for result in results {
                for value in result.songs.values {
                    songs.append(contentsOf: value)
                }
            }

            logger.notice("Multiple playlists named \"\(category) - \(name)\" found: \(results.count)")

            return MusicPlaylist(items: songs, title: name)
        }
    }

    /// Starts the timer if it is not already running.
    func startTimer() {
        logger.info("Starting library update timer.")
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                self.logger.info("Library update timer triggered.")
                self.library.updateMusic()

                DispatchQueue.main.async {
                    self.timerNextFireTime = self.timer?.fireDate

                    DispatchQueue.global().async {
                        self.loadDailyPlaylists()
                    }
                }
            }
        }
        timer?.fire()
    }

    /// Stops the timer.
    func stopTimer() {
        logger.info("Stopping library update timer.")
        timer?.invalidate()
        timer = nil
    }
}
