import Foundation
import MediaPlayer
import SwiftUI
import os

class MusaeManager: ObservableObject {
    init() {
        self.update()
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
            return (elements[0], elements[1])
        } else {
            return nil
        }
    }

    // MARK: - Public Functions
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
                self.update()
            }
        }
    }

    /// Stops the timer.
    func stopTimer() {
        logger.info("Stopping library update timer.")
        timer?.invalidate()
        timer = nil
    }

    /// Updates the music library and daily playlists.
    func update(force: Bool = false) {
        logger.log("Beginning library update process.")

        var newCategories: [String: [Playlist]] = [:]

        if let lists = MPMediaQuery.playlists().collections as? [MPMediaPlaylist] {
            for list in lists {
                if let components = self.validName(name: list.name ?? "") {
                    newCategories[components.category, default: []].append(Playlist(list, components.name))
                }
            }
        }

        if self.daily.date == nil || Calendar.current.isDateInToday(self.daily.date!) == false || force {
            self.logger.notice("Updating daily playlists.")

            let newDailyPlaylists = DailyPlaylists(newCategories)

            self.categories = newCategories
            self.daily = newDailyPlaylists
            self.lastUpdated = self.library.lastModifiedDate
        } else {
            self.categories = newCategories
            self.lastUpdated = self.library.lastModifiedDate
        }

        self.logger.log("Library updated: \(self.library.lastModifiedDate)")
    }
}
