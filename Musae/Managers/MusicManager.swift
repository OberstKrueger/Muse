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

    /// Daily playlists.
    @Published var daily: DailyPlaylists = DailyPlaylists()

    /// Date the timer will fire again.
    @Published var timerNextFireTime: Date?

    // MARK: - Public Functions
    /// Load and update daily playlists
    func loadDailyPlaylists(force: Bool = false) {
        if daily.date == nil || Calendar.current.isDateInToday(daily.date!) == false || force {
            DispatchQueue.global().async { [self] in
                let results = DailyPlaylists(library.playlists)

                DispatchQueue.main.async {
                    daily = results
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
