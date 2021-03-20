import Foundation
import MediaPlayer
import os

/// Plays provided playlists and songs through the system music player.
class MusicPlayer {
    /// System music player
    let system = MPMusicPlayerController.systemMusicPlayer

    /// System logger
    let logger = Logger(subsystem: "technology.krueger.musae", category: "player")

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
                var duration: Float64 = 0
                var songs: [MPMediaItem] = []
                var targetLength: Float64 = ((Float64(minutes) / 2) * 60) // Cut in half for two-part process.

                for song in existingPlaylist {
                    if duration < targetLength {
                        duration += song.playbackDuration
                        songs.append(song)
                    } else {
                        break
                    }
                }
                // Adjust to full-length of minutes.
                targetLength *= 2
                while duration < targetLength {
                    let random = existingPlaylist.randomElement()!

                    duration += random.playbackDuration
                    songs.append(random)
                }

                let collection = MPMediaItemCollection(items: songs)
                let descriptor = MPMusicPlayerMediaItemQueueDescriptor(itemCollection: collection)

                logger.info("Adding \(songs.count) songs to the Up Next queue.")

                DispatchQueue.main.async {
                    system.prepend(descriptor)
                }
            }
        }
    }
}
