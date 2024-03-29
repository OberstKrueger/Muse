import MediaPlayer

/// Playlist populated from a user playlist.
struct Playlist {
    init() {
        averagePlayCount = .nan
        id = 0
        length = .nan
        title = ""
        unplayed = 0
    }

    init(_ playlist: MPMediaPlaylist, _ title: String) {
        // Set averagePlayCount and length.
        if playlist.items.count == 0 {
            averagePlayCount = .nan
            length = .nan
            unplayed = 0
        } else {
            averagePlayCount = Float64(playlist.items.reduce(0, {$0 + $1.playCount})) / Float64(playlist.items.count)
            length = playlist.items.reduce(0, {$0 + $1.playbackDuration}) / 60
            unplayed = playlist.items.reduce(0, {$0 + ($1.playCount == 0 ? 1 : 0)})
        }

        // Set id.
        id = playlist.persistentID

        // Set title.
        self.title = title
    }

    /// Average playcount of all songs in the playlist.
    let averagePlayCount: Float64

    /// Persistent ID for the playlist.
    let id: MPMediaEntityPersistentID

    /// Length in minutes of the playlist.
    let length: Float64

    /// Songs that make up the playlist.
    var songs: [MPMediaItem] {
        let predicate = MPMediaPropertyPredicate(value: id,
                                                 forProperty: MPMediaPlaylistPropertyPersistentID,
                                                 comparisonType: .equalTo)
        let query = MPMediaQuery()

        query.addFilterPredicate(predicate)

        return query.items ?? []
    }

    /// Title of the playlist.
    let title: String

    /// Amount of unplayed tracks.
    let unplayed: UInt
}
