import MediaPlayer
import os

actor PlayerManager {
    /// System logger.
    private let logger = Logger(subsystem: "technology.krueger.musae", category: "player")

    /// System music player.
    private let system = MPMusicPlayerController.systemMusicPlayer

    /// Plays the provided playlist shuffled, with least played songs selected first.
    func play(_ playlist: Playlist) async {
        logger.info("Starting playlist: \(playlist.title)")

        let songs = Dictionary(grouping: playlist.songs, by: {$0.playCount})
        var toPlay: [MPMediaItem] = []

        for (_, value) in songs.sorted(by: {$0.key < $1.key}) {
            toPlay.append(contentsOf: value.shuffled())
        }

        let collection = MPMediaItemCollection(items: toPlay)

        await MainActor.run {
            system.setQueue(with: collection)
            system.prepareToPlay()
            system.repeatMode = .all
            system.shuffleMode = .off
            system.play()
        }
    }

    /// Adds a random song from the playlist to the Up Next queue, ignoring play counts.
    func random(_ playlist: Playlist) async {
        logger.info("Adding random song to up next: \(playlist.title)")

        let random: MPMediaItem?
        let unplayed = playlist.songs.filter({$0.playCount == 0})

        if unplayed.isEmpty {
            random = playlist.songs.randomElement()
        } else {
            random = unplayed.randomElement()
        }

        switch random {
        case .none:
            logger.info("Could not retrieve a random song from playlist: \(playlist.title)")
        case .some(let song):
            logger.info("Adding random song to Up Next Queue: \(song.title!).")

            let collection = MPMediaItemCollection(items: [song])
            let descriptor = MPMusicPlayerMediaItemQueueDescriptor(itemCollection: collection)

            await MainActor.run {
                system.prepend(descriptor)
            }
        }
    }

    /// Adds assortment of items to the Up Next queue, favoring lesser played items.
    func upNext(_ playlist: Playlist) async {
        logger.info("Adding to up next: \(playlist.title)")

        let minutes = 30

        let items = Dictionary(grouping: playlist.songs, by: {$0.playCount})
        let playlistTotal: Float64 = playlist.songs.reduce(0, {$0 + $1.playbackDuration})

        var duration: Float64 = 0
        var songs: [MPMediaItem] = []
        var target: Float64 = (Float64(minutes) * 60) / 2   // Cut in half for two-part response.

        if playlistTotal > (target * 2) {
            logger.info("Playlist length is longer than user settings value.")

            firstPass: for (_, value) in items.sorted(by: {$0.key < $1.key}) {
                for song in value.shuffled() {
                    logger.info("Adding song to Up Next Queue: \(song.title!), \(song.playCount) plays.")

                    duration += song.playbackDuration
                    songs.append(song)

                    if duration > target { break firstPass }
                }
            }

            target *= 2

            while duration < target {
                let song = playlist.songs.randomElement()!

                if songs.contains(song) == false {
                    logger.info("Adding song to Up Next Queue: \(song.title!), \(song.playCount) plays.")

                    duration += song.playbackDuration
                    songs.append(song)
                }
            }

            songs.shuffle()
        } else {
            logger.info("Playlist length is shorter than user settings value.")

            duration = playlistTotal
            songs = playlist.songs.shuffled()
            target *= 2

            while duration < target {
                let random = playlist.songs.randomElement()!

                duration += random.playbackDuration
                songs.append(random)
            }
        }

        let collection = MPMediaItemCollection(items: songs)
        let descriptor = MPMusicPlayerMediaItemQueueDescriptor(itemCollection: collection)

        logger.info("Adding \(songs.count) songs to the Up Next queue.")
        logger.info("Total song length added: \(songs.reduce(0, {$0 + $1.playbackDuration})) seconds.")

        await MainActor.run {
            system.prepend(descriptor)
        }
    }
}
