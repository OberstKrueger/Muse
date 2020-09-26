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
}
