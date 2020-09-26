import Foundation
import MediaPlayer

/// Plays provided playlists and songs through the system music player.
class MusicPlayer {
    /// System music player
    let system = MPMusicPlayerController.systemMusicPlayer

    /// Plays the provided playlist shuffled, with least played songs played first.
    func play(playlist: MusicLibraryPlaylist?) {
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
    func upNext(playlist: MusicLibraryPlaylist?) {
        if let existingPlaylist = playlist {
            DispatchQueue.global().async { [self] in
                var songs: [MPMediaItem] = []
                var totalDuration: Float64 = 0

                for (_, value) in existingPlaylist.songs.sorted(by: {$0.key < $1.key}) {
                    var upcomingSongs = value.shuffled()

                    while totalDuration < Float64(32 * 60) && upcomingSongs.isEmpty == false {
                        if let song = upcomingSongs.popLast() {
                            songs.append(song)
                            totalDuration += song.playbackDuration
                        }
                    }

                    if totalDuration > (32 * 60) {
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
