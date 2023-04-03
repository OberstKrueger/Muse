import MediaPlayer

/// Collection of playlists from the user's music library that all of the same category
struct Category {
    /// All empty playlists in a user's music library.
    var emptyPlaylists: [Playlist] = []

    /// All normal playlists in a user's music library.
    var playlists: [Playlist] = []

    /// All short playlists in a user's music library.
    var shortPlaylists: [Playlist] = []

    /// All playlists in a user's music library with unplayed songs.
    var unplayedPlaylists: [Playlist] = []

    /// All playlists in a user's music library.
    /// - Note: The array that is returned is unsorted.
    var combinedPlaylists: [Playlist] { return playlists + emptyPlaylists + shortPlaylists + unplayedPlaylists }

    /// The title of the category.
    var title: String

    /// Adds a playlist to the appropriate array.
    mutating func add(_ playlist: MPMediaPlaylist, _ title: String) {
        let new = Playlist(playlist, title)

        if new.length.isNaN {
            emptyPlaylists.append(new)
        } else if new.length < 30 {
            shortPlaylists.append(new)
        } else if new.unplayed > 0 {
            unplayedPlaylists.append(new)
        } else {
            playlists.append(new)
        }
    }
}
