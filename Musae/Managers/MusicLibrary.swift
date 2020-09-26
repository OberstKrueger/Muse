import Combine
import Foundation
import MediaPlayer

/// Library manager. Loads and updates playlists from the users music library.
class MusicLibrary: ObservableObject {
    // MARK: - GENERAL
    /// OS-provided media library.
    let library = MPMediaLibrary()

    /// Date the library was last updated.
    var lastUpdated: Date?

    /// Set of playlists, organized by category.
    @Published var playlists: [String: [String: MusicLibraryPlaylist]] = [:]

    // MARK: - LOADING AND UPDATING MUSIC
    /// Whether the library is currently being loaded.
    var libraryLoading: Bool = false

    /// Loads playlists and categories from music library.
    func loadMusic() {
        if libraryLoading == false {
            libraryLoading = true

            DispatchQueue.global().async { [self] in
                let libraryLastModifiedDate = library.lastModifiedDate
                var libraryPlaylists: [String: [String: MusicLibraryPlaylist]] = [:]

                if let lists = MPMediaQuery.playlists().collections as? [MPMediaPlaylist] {
                    for list in lists {
                        if let nameComponents = validName(name: list.name ?? "") {
                            var newPlaylist = MusicLibraryPlaylist()

                            for song in list.items {
                                newPlaylist.add(song)
                            }

                            libraryPlaylists[nameComponents.category, default: [:]][nameComponents.name] = newPlaylist
                        }
                    }

                    DispatchQueue.main.async {
                        playlists = libraryPlaylists
                        lastUpdated = libraryLastModifiedDate

                        libraryLoading = false
                    }
                }
            }
        }
    }

    /// Updates playlists if they have been changed.
    func updateMusic() {
        if let last = lastUpdated {
            if library.lastModifiedDate > last {
                loadMusic()
            }
        } else {
            loadMusic()
        }
    }

    /// Checks if the playlist has a valid name.
    fileprivate func validName(name: String) -> (category: String, name: String)? {
        let elements = name.components(separatedBy: " - ")

        if elements.count == 2 {
            return (elements[0], elements[1])
        } else {
            return nil
        }
    }

    // MARK: - INITIALIZATION
    init() {
        updateMusic()
    }
}

struct MusicLibraryPlaylist {
    /// Songs in playlist, organized by playcount.
    var songs: [Int: [MPMediaItem]] = [:]

    /// Average playcount of all songs in the playlist.
    var averagePlayCount: Float64 {
        if songs.count == 0 { return 0 }

        var count: Float64 = 0
        var total: Int = 0

        for array in songs.values {
            for song in array {
                count += 1
                total += song.playCount
            }
        }

        return Float64(total) / count
    }

    /// Adds a song to the playlist.
    mutating func add(_ song: MPMediaItem) {
        songs[song.playCount, default: []].append(song)
    }
}
