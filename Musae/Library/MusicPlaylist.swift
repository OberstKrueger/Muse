import MediaPlayer

/// Playlist populated from a user playlist
struct MusicPlaylist {
    /// Songs in playlist, organized by playcount.
    var songs: [Int: [MPMediaItem]] = [:]

    /// Average playcount of all songs in the playlist.
    var averagePlayCount: Float64 {
        if songs.count == 0 { return 0 }

        let count: Int = songs.values.flatMap({$0}).count
        let total: Int = songs.reduce(0, {$0 + ($1.key * $1.value.count)})

        return Float64(total) / Float64(count)
    }

    init(_ items: [MPMediaItem]) {
        self.songs = Dictionary(grouping: items, by: {$0.playCount})
    }
}
