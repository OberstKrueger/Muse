import Foundation
import MediaPlayer
import os

/// Plays provided playlists and songs through the system music player.
class MusicPlayer {
    // MARK: - Internal Properties
    /// System music player
    let system = MPMusicPlayerController.systemMusicPlayer

    /// System logger
    let logger = Logger(subsystem: "technology.krueger.musae", category: "player")

    // MARK: - Public Functions
    /// Plays the provided playlist shuffled, with least played songs played first.
    func play(playlist: MusicPlaylist?, category: String) {
        logger.info("Starting playlist: \(category) - \(playlist?.title ?? "no playlist provided")")
        if let existingPlaylist = playlist {
            DispatchQueue.global().async { [self] in
                var songs: [MPMediaItem] = []

                for (_, value) in existingPlaylist.songs.sorted(by: {$0.key < $1.key}) {
                    songs.append(contentsOf: value.shuffled())
                }

                let collection = MPMediaItemCollection(items: songs)

                DispatchQueue.main.async {
                    system.setQueue(with: collection)
                    system.prepareToPlay()
                    system.play()
                }
            }
        }
    }

    /// Adds least played items from provided playlist to the Up Next queue.
    func upNext(playlist: MusicPlaylist?, category: String, minutes: Int) {
        logger.info("Adding to up next: \(category) - \(playlist?.title ?? "no playlist provided")")
        if let existingPlaylist = playlist?.songs.sorted(by: {$0.key < $1.key}).flatMap({$0.value.shuffled()}) {
            DispatchQueue.global().async { [self] in
                let playlistTotal = existingPlaylist.reduce(0, {$0 + $1.playbackDuration})

                var duration: Float64 = 0
                var songs: [MPMediaItem] = []
                var targetLength: Float64 = (Float64(minutes) * 60) / 2     // Cut in half for two-part process.

                if playlistTotal > Float64(minutes * 60) {
                    logger.info("Playlist length exceeds user settings value.")

                    for song in existingPlaylist {
                        duration += song.playbackDuration
                        songs.append(song)

                        if duration > targetLength { break }
                    }

                    targetLength *= 2

                    while duration < targetLength {
                        let randomSong = existingPlaylist.randomElement()!

                        if songs.contains(randomSong) == false {
                            duration += randomSong.playbackDuration
                            songs.append(randomSong)
                        }
                    }

                    songs.shuffle()
                } else {
                    logger.info("Playlist length below mininum user settings value.")

                    duration = playlistTotal
                    songs = existingPlaylist.shuffled()
                    targetLength *= 2   // Two-part process unnecessary

                    while duration < targetLength {
                        let randomSong = existingPlaylist.randomElement()!

                        duration += randomSong.playbackDuration
                        songs.append(randomSong)
                    }
                }

                let collection = MPMediaItemCollection(items: songs)
                let descriptor = MPMusicPlayerMediaItemQueueDescriptor(itemCollection: collection)

                logger.info("Adding \(songs.count) songs to the Up Next queue.")
                logger.info("Total song length added: \(songs.reduce(0, {$0 + $1.playbackDuration})) seconds.")

                DispatchQueue.main.async {
                    system.prepend(descriptor)
                }
            }
        }
    }
}
