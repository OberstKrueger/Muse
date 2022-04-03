import MediaPlayer
import os

class PlayerManager {
    // MARK: - Internal Properties
    /// System logger.
    fileprivate let logger = Logger(subsystem: "technology.krueger.musae", category: "player")

    /// System music player.
    fileprivate let system = MPMusicPlayerController.systemMusicPlayer

    // MARK: - Public Functions
    /// Plays the provided playlist shuffled, with least played songs selected first.
    func play(_ playlist: Playlist) {
        logger.info("Starting playlist: \(playlist.title)")

        let songs = Dictionary(grouping: playlist.songs, by: {$0.playCount})
        var toPlay: [MPMediaItem] = []

        for (_, value) in songs.sorted(by: {$0.key < $1.key}) {
            toPlay.append(contentsOf: value.shuffled())
        }

        let collection = MPMediaItemCollection(items: toPlay)

        system.setQueue(with: collection)
        system.prepareToPlay()
        system.play()
    }

    /// Adds assortment of items to the Up Next queue, favoring lesser played items.
    func upNext(_ playlist: Playlist, _ minutes: Int) {
        logger.info("Adding to up next: \(playlist.title)")

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

        system.prepend(descriptor)
    }
}
