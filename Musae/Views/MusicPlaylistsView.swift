import SwiftUI

struct MusicPlaylistsView: View {
    @ObservedObject var library: MusicLibrary

    var body: some View {
        Text("MusicPlaylistsView")
    }
}

struct MusicPlaylistsView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlaylistsView(library: MusicLibrary())
    }
}
