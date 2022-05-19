import Foundation
import MediaPlayer
import SwiftUI
import os

class MusaeManager: ObservableObject {
    init() {
        logger.info("Initializing MusaeManager")
    }

    /// OS-provided media library.
    private let library = MPMediaLibrary()

    /// System logger.
    private let logger = Logger(subsystem: "technology.krueger.musae", category: "library")

    /// Categories from the user's music library.
    @Published var categories: [Category] = []

    /// Daily playlists.
    @Published var daily = DailyPlaylists()

    /// Date the library was last updated.
    @Published var lastUpdated: Date?

    /// Timer for refreshing the music library.
    private var timer: Timer?

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

        let query = MPMediaQuery.playlists()
        var updatedCategories: [String: Category] = [:]

        if let playlists = query.collections as? [MPMediaPlaylist] {
            for item in playlists {
                if let components = item.nameComponents {
                    updatedCategories[components.category, default: Category(title: components.category)]
                        .add(item, components.name)
                }
            }
        }

        let sortedCategories = updatedCategories.values.sorted(by: {$0.title < $1.title})

        if Calendar.current.isDateInToday(self.daily.date) == false {
            self.logger.notice("Updating daily playlists.")

            self.daily = DailyPlaylists(sortedCategories)
        }

        self.categories = sortedCategories
        self.lastUpdated = self.library.lastModifiedDate

        self.logger.log("Library updated: \(self.library.lastModifiedDate)")
    }
}
