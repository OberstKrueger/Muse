import Foundation
import MediaPlayer
import os

class LibraryManager {
    // MARK: - Internal Properties
    /// OS-provided media library.
    fileprivate let library = MPMediaLibrary()

    /// System logger.
    fileprivate let logger = Logger(subsystem: "technology.krueger.musae", category: "library")

    // MARK: - Public Proeprties
    /// Set of playlists organized by category.
    var categories: [String: [Playlist]] = [:]

    /// Daily playlists.
    var daily: DailyPlaylists = DailyPlaylists()

    /// Date the library was last updated.
    var lastUpdated: Date?

    /// Timer for refreshing the music library.
    var timer: Timer?

    // MARK: - Internal Functions
    /// Checks if the playlist has a valid name.
    fileprivate func validName(name: String) -> (category: String, name: String)? {
        let elements = name.components(separatedBy: " - ")

        if elements.count == 2 {
            logger.debug("Playlist name is valid: \(name)")
            return (elements[0], elements[1])
        } else {
            logger.debug("Playlist name is invalid: \(name)")
            return nil
        }
    }

    // MARK: - Public Functions
    /// Load and update daily playlists
    func loadDailyPlaylists(force: Bool = false) {
        if daily.date == nil || Calendar.current.isDateInToday(daily.date!) == false || force {
            DispatchQueue.global().async { [self] in
                logger.notice("Updating daily playlists.")
                let results = DailyPlaylists(categories)

                DispatchQueue.main.async { [self] in
                    logger.notice("Daily playlist update is complete.")
                    print(daily.playlists)
                    daily = results
                }
            }
        }
    }

    /// Starts the timer if it is not already running.
    func startTimer() {
        logger.info("Starting library update timer.")
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                self.logger.info("Library update timer triggered.")
                self.updateMusic()
                self.loadDailyPlaylists()
            }
        }
    }

    /// Stops the timer.
    func stopTimer() {
        logger.info("Stopping library update timer.")
        timer?.invalidate()
        timer = nil
    }

    func updateMusic() {
        logger.log("Beginning library update process.")
        if lastUpdated != library.lastModifiedDate {
            logger.log("Library updated: \(self.library.lastModifiedDate)")
            var newCategories: [String: [Playlist]] = [:]

            if let lists = MPMediaQuery.playlists().collections as? [MPMediaPlaylist] {
                for list in lists {
                    if let components = validName(name: list.name ?? "") {
                        newCategories[components.category, default: []].append(Playlist(list))
                    }
                }

                if Thread.isMainThread {
                    self.categories = newCategories
                    self.lastUpdated = library.lastModifiedDate
                } else {
                    DispatchQueue.main.async {
                        self.categories = newCategories
                        self.lastUpdated = self.library.lastModifiedDate
                    }
                }
            }
        } else {
            logger.log("Library not updated.")
        }
    }
}
