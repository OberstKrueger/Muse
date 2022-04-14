import SwiftUI

struct MusicPlaylistsView: View {
    var categories: [Category]
    var daily: DailyPlaylists

    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.title) { category in
                    let daily = daily.playlists[category.title, default: Playlist()].title
                    let playlists = category.combinedPlaylists
                        .sorted(by: { $0.averagePlayCount.isTotallyOrdered(belowOrEqualTo: $1.averagePlayCount) })
                        .map({($0.title, $0.averagePlayCount)})

                    MusicPlaylistsSectionView(category: category.title, dailyName: daily, playlists: playlists)
                }
            }
            .navigationTitle("Playlists")
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
        MusicPlaylistsView(categories: [], daily: DailyPlaylists())
    }
}
