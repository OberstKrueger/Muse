import MediaPlayer

/// Playlist populated from a user playlist
struct MusicPlaylist {
    // MARK: - Initializations
    init(items: [MPMediaItem], title: String) {
        self.songs = Dictionary(grouping: items, by: {$0.playCount})
        self.title = title
    }
    
    // MARK: - Public Properties
    /// Songs in playlist, organized by playcount.
    var songs: [Int: [MPMediaItem]] = [:]

    /// Title of the playlist
    var title: String

    /// Average playcount of all songs in the playlist.
    var averagePlayCount: Float64 {
        if songs.count == 0 { return .nan }

        let count: Int = songs.values.flatMap({$0}).count
        let total: Int = songs.reduce(0, {$0 + ($1.key * $1.value.count)})

        return Float64(total) / Float64(count)
    }
}
