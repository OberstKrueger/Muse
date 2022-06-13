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

    /// Task for refreshing the music library.
    private var task: Task<Void, Never>?

    /// Refreshes the user library every 30 seconds until cancelled.
    func refreshTask() {
        logger.info("Library refresh task triggered.")

        task = Task {
            await update()
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            if Task.isCancelled {
                return
            }
            refreshTask()

            // For this, change it so that update returns the results, which can then be passed to a function that
            // stores it from the main thread.
        }
    }

    /// Stops the timer.
    func stopRefreshTask() {
        logger.info("Stopping library refresh task.")
        task?.cancel()
    }

    /// Updates the music library and daily playlists.
    func update() async {
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

            await MainActor.run {
                self.daily = DailyPlaylists(sortedCategories)
            }
        }

        await MainActor.run {
            self.categories = sortedCategories
            self.lastUpdated = self.library.lastModifiedDate
        }

        self.logger.log("Library updated: \(self.library.lastModifiedDate)")
    }
}
