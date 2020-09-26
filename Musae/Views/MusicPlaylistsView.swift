import SwiftUI

struct MusicPlaylistsView: View {
    @ObservedObject var library: MusicLibrary

    var body: some View {
        NavigationView {
            List {
                ForEach(library.playlists.keys.sorted(), id: \.self) { key in
                    Section(header: Text(key)) {
                        let dailyName = library.dailyPlaylists[key, default: ""]

                        ForEach(library.playlists[key, default: [:]].sorted(by: {$0.key < $1.key}), id: \.key) { list in
                            MusicPlaylistsItemView(daily: dailyName == list.key,
                                                   name: list.key,
                                                   playcount: list.value.averagePlayCountPrint)
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
    var daily: Bool
    var name: String
    var playcount: String

    var body: some View {
        HStack {
            if daily {
                Text(name)
                    .fontWeight(.black)
            } else {
                Text(name)
            }
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
