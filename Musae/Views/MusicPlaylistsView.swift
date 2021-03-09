import Foundation
import SwiftUI

struct MusicPlaylistsView: View {
    @EnvironmentObject var settings: MusicSettings
    @ObservedObject var library: MusicManager

    let formatter = NumberFormatter()

    var body: some View {
        NavigationView {
            List {
                ForEach(library.library.playlists.keys.sorted(), id: \.self) { key in
                    let daily = library.daily.playlists[key, default: ""]
                    let playlists = library.library.playlists[key, default: []]
                        .sorted(by: {settings.sortByAveragePlayCount ?
                                    $0.averagePlayCount < $1.averagePlayCount :
                                    $0.title < $1.title})
                        .map({($0.title, formatPlayCount($0.averagePlayCount))})

                    MusicPlaylistsSectionView(category: key,
                                              dailyName: daily,
                                              playlists: playlists)
                }
            }
            .navigationTitle("Playlists")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    /// Formats a playcount to display 2 decimal places.
    func formatPlayCount(_ playcount: Float64) -> String {
        return formatter.string(from: playcount as NSNumber) ?? "0"
    }

    init(library: MusicManager) {
        self.library = library

        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.roundingMode = .halfUp
    }
}

struct MusicPlaylistsSectionView: View {
    let category: String
    let dailyName: String
    let playlists: [(name: String, playcount: String)]

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
        MusicPlaylistsView(library: MusicManager()).environmentObject(MusicSettings())
    }
}
