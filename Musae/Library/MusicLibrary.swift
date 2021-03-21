import Foundation
import MediaPlayer

/// Provides access to the user's music library
class MusicLibrary {
    // MARK: - Internal Properties
    /// OS-provided media library.
    let library = MPMediaLibrary()

    // MARK: - Public Properties
    /// Date the library was last updated.
    var lastUpdated: Date?

    /// Set of playlists, organized by category.
    var playlists: [String: [MusicPlaylist]] = [:]

    // MARK: - Internal Functiones
    /// Checks if the playlist has a valid name.
    fileprivate func validName(name: String) -> (category: String, name: String)? {
        let elements = name.components(separatedBy: " - ")

        if elements.count == 2 {
            return (elements[0], elements[1])
        } else {
            return nil
        }
    }

    // MARK: - Public FUnctions
    /// Loads playlists and categories from music library.
    func loadMusic() {
        let libraryLastModifiedDate = library.lastModifiedDate
        var libraryPlaylists: [String: [MusicPlaylist]] = [:]

        if let lists = MPMediaQuery.playlists().collections as? [MPMediaPlaylist] {
            for list in lists {
                if let nameComponents = validName(name: list.name ?? "") {
                    let newPlaylist = MusicPlaylist(items: list.items, title: nameComponents.name)

                    libraryPlaylists[nameComponents.category, default: []].append(newPlaylist)
                }
            }

            if Thread.isMainThread {
                self.playlists = libraryPlaylists
                self.lastUpdated = libraryLastModifiedDate
            } else {
                DispatchQueue.main.async {
                    self.playlists = libraryPlaylists
                    self.lastUpdated = libraryLastModifiedDate
                }
            }
        }
    }

    /// Updates playlists if they have been changed.
    func updateMusic() {
        if let last = lastUpdated {
            if library.lastModifiedDate != last {
                loadMusic()
            }
        } else {
            loadMusic()
        }
    }
}
