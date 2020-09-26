import SwiftUI

struct MusicPlaylistsView: View {
    @ObservedObject var library: MusicLibrary

    var body: some View {
        NavigationView {
            List {
                ForEach(library.playlists.keys.sorted(), id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach(library.playlists[key, default: [:]].sorted(by: {$0.key < $1.key}), id: \.key) { list in
                            MusicPlaylistsItemView(name: list.key, playcount: list.value.averagePlayCountPrint)
                        }
                    }
                }
            }
            .navigationTitle("Playlists")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MusicPlaylistsItemView: View {
    var name: String
    var playcount: String

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text("\(playcount)")
        }
    }
}

struct MusicPlaylistsView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlaylistsView(library: MusicLibrary())
    }
}
