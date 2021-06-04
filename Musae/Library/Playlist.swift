import MediaPlayer

/// Playlist populated from a user playlist.
struct Playlist {
    // MARK: - Initializations
    init(_ playlist: MPMediaPlaylist) {
        // Set id.
        id = playlist.persistentID

        // Set averagePlayCount.
        if playlist.items.count == 0 {
            averagePlayCount = .nan
        } else {
            averagePlayCount = Float64(playlist.items.reduce(0, {$0 + $1.playCount})) / Float64(playlist.items.count)
        }

        // Set title.
        title = playlist.name ?? "Unnamed Playlist"

    }

    // MARK: - Public Properties
    /// Average playcount of all songs in the playlist.
    let averagePlayCount: Float64

    /// Persistent ID for the playlist.
    let id: MPMediaEntityPersistentID

    /// Title of the playlist.
    let title: String
}
