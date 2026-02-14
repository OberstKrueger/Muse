import Foundation
import MediaPlayer
import Observation
import os

@MainActor
@Observable
class MuseModel {
        init() {
            logger.info("Initializing MuseModel")
        }

        var authorizationStatus: AuthorizationStatus { authorizer.status }

        var folders: [Folder] = []

        /// Music library authorization service.
        private let authorizer = AuthorizationManager()

        /// Music library service.
        private let library = LibraryService()

        /// System logger.
        @ObservationIgnored
        private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "technology.krueger.muse", category: "MuseModel")

        func requestAuthorization() {
            authorizer.requestAuthorization()
        }

        func update() {
            Task {
                folders = await library.fetch()
            }
        }
}
