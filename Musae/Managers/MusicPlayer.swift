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
    func upNext(playlist: MusicPlaylist?, category: String, minutes: UInt) {
        logger.info("Adding to up next: \(category) - \(playlist?.title ?? "no playlist provided")")
        if let existingPlaylist = playlist {
            DispatchQueue.global().async { [self] in
                var songs: [MPMediaItem] = []
                var totalDuration: Float64 = 0

                for (_, value) in existingPlaylist.songs.sorted(by: {$0.key < $1.key}) {
                    var upcomingSongs = value.shuffled()

                    while totalDuration < Float64(minutes * 60) && upcomingSongs.isEmpty == false {
                        if let song = upcomingSongs.popLast() {
                            songs.append(song)
                            totalDuration += song.playbackDuration
                        }
                    }

                    if totalDuration > Float64(minutes * 60) {
                        break
                    }
                }

                let collection = MPMediaItemCollection(items: songs)
                let descriptor = MPMusicPlayerMediaItemQueueDescriptor(itemCollection: collection)

                DispatchQueue.main.async {
                    system.prepend(descriptor)
                }
            }
        }
    }
}
