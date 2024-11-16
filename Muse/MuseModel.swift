import Foundation
#warning("TODO: Remove this - import MediaPlayer")
import SwiftUI
import os

@MainActor
class MuseModel: ObservableObject {
    init() {
        logger.info("Initializing MuseModel")
    }

    /// Music library service.
    private let library = LibraryService()

    /// System logger.
    private let logger = Logger(subsystem: "technology.krueger.muse", category: "MuseModel")

    /// Media player service.
    private let player = PlayerService()

    /// Categories from the user's music library.
    @Published var categories: [Category] = []

    #warning("TODO: Daily playlists, but rework to simply be a list of playlists and a last updated date. Or something that perhaps simply pulls from Defaults. Just not the overwrought structure as it is now.")

    /// Daily playlists
    @Published var dailies: [Playlist] = []

    /// Date the daily playlists were last updated.
    @Published var dailiesUpdated: Date?

    /// Date the library was last updated.
    @Published var libraryUpdated: Date?

    #warning("TODO: func refreshTask() needs a rethink most likley")

    #warning("TODO: func stopRefreshTask() might need a rethink.")

    #warning("TODO: func update() definitely needs a refresh.")
}

class MuseManager: ObservableObject {
    init() {
        logger.info("Initializing MuseManager")
    }

    /// OS-provided media library.
    private let library = MPMediaLibrary()

    /// System logger.
    private let logger = Logger(subsystem: "technology.krueger.muse", category: "library")

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
            try? await Task.sleep(for: .seconds(30))
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
