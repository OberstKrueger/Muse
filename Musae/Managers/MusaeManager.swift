import Foundation
import MediaPlayer
import SwiftUI
import os

class MusaeManager: ObservableObject {
    // MARK: - Initialization and Deinitialization
    init() {
        logger.info("Initializing MusaeManager")
    }

    deinit {
        logger.info("Deinitializing MusaeManager")
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
    @Published var daily = DailyPlaylists()

    /// Date the library was last updated.
    @Published var lastUpdated: Date?

    /// Timer for refreshing the music library.
    var timer: Timer?

    // MARK: - Public Functions
    /// Starts the timer if it is not already running.
    func startTimer() {
        update()
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
    func update() {
        logger.log("Beginning library update process.")

        var newCategories: [String: [Playlist]] = [:]

        if let lists = MPMediaQuery.playlists().collections as? [MPMediaPlaylist] {
            for list in lists {
                if let components = list.nameComponents {
                    newCategories[components.category, default: []].append(Playlist(list, components.name))
                }
            }
        }

        if Calendar.current.isDateInToday(self.daily.date) == false {
            self.logger.notice("Updating daily playlists.")

            self.daily = DailyPlaylists(newCategories)
        }

        self.categories = newCategories
        self.lastUpdated = self.library.lastModifiedDate
//        self.statistics.update(categories: newCategories)

        self.logger.log("Library updated: \(self.library.lastModifiedDate)")
    }
}
