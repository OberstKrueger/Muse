import SwiftUI

struct MusicPlaylistsView: View {
    @EnvironmentObject var settings: MusicSettings
    @ObservedObject var library: LibraryManager

    let formatter = NumberFormatter()

    var body: some View {
        NavigationView {
            List {
                ForEach(library.categories.keys.sorted(), id: \.self) { key in
                    let daily = library.daily.playlists[key, default: ""]
                    let playlists = library.categories[key, default: []]
                        .sorted(by: {settings.sortByAveragePlayCount ?
                            $0.averagePlayCount < $1.averagePlayCount :
                            $0.title < $1.title
                        })
                        .map({($0.title, $0.averagePlayCount)})

                    MusicPlaylistsSectionView(category: key, dailyName: daily, playlists: playlists)

                }
            }
            .navigationTitle("Playlists")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    init(library: LibraryManager) {
        self.library = library
    }
}

struct MusicPlaylistsSectionView: View {
    let category: String
    let dailyName: String
    let playlists: [(name: String, playcount: Float64)]

    var body: some View {
        Section(header: Text(category)) {
            ForEach(playlists, id: \.name) { list in
                MusicPlaylistsItemView(daily: list.name == dailyName, name: list.name, playcount: list.playcount)
            }
        }
    }
}

struct MusicPlaylistsItemView: View {
    var daily: Bool
    var name: String
    var playcount: Float64

    var body: some View {
        HStack {
            if daily {
                Text(name)
                    .fontWeight(.black)
            } else {
                Text(name)
            }
            Spacer()
            Text("\(playcount, specifier: "%.2f")")
        }
    }
}

struct MusicPlaylistsView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlaylistsView(library: LibraryManager()).environmentObject(MusicSettings())
    }
}
