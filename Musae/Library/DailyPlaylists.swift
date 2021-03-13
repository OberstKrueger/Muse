import Foundation

/// Daily playlists for the library.
struct DailyPlaylists {
    /// Date dailiy playlists were updated.
    var date: Date?

    /// Daily playlists by category.
    var playlists: [String: String] = [:]

    init() { playlists = [:] }

    init(_ libraryPlaylists: [String: [MusicPlaylist]]) {
        for key in libraryPlaylists.keys {
            /// Results with an average playcount above or equal to 1.
            let resultsAll: [String] = libraryPlaylists[key, default: []]
                .filter({$0.averagePlayCount.isNaN == false})
                .sorted(by: {$0.averagePlayCount < $1.averagePlayCount})
                .map({($0.title)})
            /// Results with an average playcount below 1.
            let resultsBelow: [String] = libraryPlaylists[key, default: []]
                .filter({$0.averagePlayCount < 1})
                .map({$0.title})

            if let playlist = resultsBelow.randomElement() {
                playlists[key] = playlist
            } else {
                switch resultsAll.count {
                case ...0: playlists[key] = "No valid playlists"
                case ...4: playlists[key] = resultsAll[0]
                case ...8: playlists[key] = resultsAll[...3].randomElement()!
                default:   playlists[key] = resultsAll[...7].randomElement()!
                }
            }
        }

        date = Date()
    }
}
