import Foundation
import MediaPlayer
import SwiftUI
import os

class LibraryManager: ObservableObject {
    // MARK: - Initializers
    init() {
        startTimer()
    }

    // MARK: - Internal Properties
    /// OS-provided media library.
    fileprivate let library = MPMediaLibrary()

    /// System logger.
    fileprivate let logger = Logger(subsystem: "technology.krueger.musae", category: "library")

    // MARK: - Public Proeprties
    /// Set of playlists organized by category.
    @Published var categories: [String: [Playlist]] = [:]

    /// Daily playlists.
    @Published var daily: DailyPlaylists = DailyPlaylists()

    /// Date the library was last updated.
    @Published var lastUpdated: Date?

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
            logger.notice("Updating daily playlists.")
            daily = DailyPlaylists(categories)
        }
    }

    func playlistByName(category: String, name: String) -> Playlist? {
        let results = categories[category, default: []].filter({$0.title == name})

        switch results.count {
        case ...0:
            logger.notice("Playlist \"\(category) - \(name)\" was not found in the library.")
            return nil
        case 1:
            return results[0]
        default:
            logger.notice("Multiple playlists named \"\(category) - \(name)\" found: \(results.count)")
            return nil
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
        timer?.fire()
    }

    /// Stops the timer.
    func stopTimer() {
        logger.info("Stopping library update timer.")
        timer?.invalidate()
        timer = nil
    }

    func updateMusic() {
        logger.log("Beginning library update process.")

        var newCategories: [String: [Playlist]] = [:]

        if let lists = MPMediaQuery.playlists().collections as? [MPMediaPlaylist] {
            for list in lists {
                if let components = validName(name: list.name ?? "") {
                    newCategories[components.category, default: []].append(Playlist(list, components.name))
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

        logger.log("Library updated: \(self.library.lastModifiedDate)")
    }
}
