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

    // MARK: - DAILY PLAYLISTS
    /// Daily playlists by category
    @Published var dailyPlaylists: [String: String] = [:]
    /// Date the daily playlists were last updated.
    @Published var dailyPlaylistDate: Date?

    /// Load and update daily playlists
    func loadDailyPlaylists(force: Bool = false) {
        if dailyPlaylistDate == nil || Calendar.current.isDateInToday(dailyPlaylistDate!) == false || force {
            DispatchQueue.global().async { [self] in
                var results: [String: String] = [:]

                for key in playlists.keys {
                    let sortedPlaylists = playlists[key, default: [:]]
                        .sorted(by: {$0.value.averagePlayCount < $1.value.averagePlayCount})
                        .map({($0.key)})

                    switch sortedPlaylists.count {
                    case ...0: results[key] = "Empty category!"
                    case ...4: results[key] = sortedPlaylists[0]
                    case ...8: results[key] = sortedPlaylists[...3].randomElement()!
                    default:   results[key] = sortedPlaylists[...7].randomElement()!
                    }
                }

                DispatchQueue.main.async {
                    dailyPlaylists = results
                    dailyPlaylistDate = Date()
                }
            }
        }
    }

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

                        loadDailyPlaylists()

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

    // MARK: - TIMERS
    /// Timer for refreshing the music library.
    var timer: Timer?

    /// Starts the timer if it is not already running.
    func startTimer() {
        print("Starting timer.")
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                print("Timer triggered: \(Date()).")
                self.updateMusic()
            }
        }
        timer?.fire()
    }

    /// Stops the timer.
    func stopTimer() {
        print("Stopping timer.")
        timer?.invalidate()
        timer = nil
    }

    // MARK: - INITIALIZATION
    init() {
        startTimer()
    }
}

/// Playlist populated from a user playlist
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

    /// Average play count of all songs in the playlist, formatted to 2 decimal places.
    var averagePlayCountPrint: String {
        let formatter = NumberFormatter()

        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.roundingMode = .halfUp

        return formatter.string(from: averagePlayCount as NSNumber) ?? "0"
    }

    /// Adds a song to the playlist.
    mutating func add(_ song: MPMediaItem) {
        songs[song.playCount, default: []].append(song)
    }
}
