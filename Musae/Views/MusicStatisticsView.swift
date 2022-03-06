import SwiftUI

struct MusicStatisticsView: View {
    @ObservedObject var library: MusaeManager

    var smallPlaylists: [String] {
        var results: [String] = []

        for (category, playlists) in library.categories {
            for playlist in playlists {
                if Int(playlist.length) < 30 {
                    results.append("\(category) - \(playlist.title)")
                }
            }
        }

        return results.sorted()
    }

    var unplayedPlaylists: [(String, UInt)] {
        var results: [(String, UInt)] = []

        for (category, playlists) in library.categories {
            for playlist in playlists where playlist.unplayed > 0 {
                results.append(("\(category) - \(playlist.title)", playlist.unplayed))
            }
        }

        return results.sorted(by: {$0.0 < $1.0})
    }

    var body: some View {
        NavigationView {
            Form {
                if smallPlaylists.count > 0 {
                    Section(header: Text("Small Playlists")) {
                        ForEach(smallPlaylists, id: \.self) { playlist in
                            Text(playlist)
                        }
                    }
                }
                if unplayedPlaylists.count > 0 {
                    Section(header: Text("Unplayed Playlists")) {
                        ForEach(unplayedPlaylists, id: \.0) { title, count in
                            Text("\(title): \(count)")
                        }
                    }
                }
                if let date = library.lastUpdated {
                    Text("Updated: \(date.formatted(.dateTime.year().month(.wide).day().hour().minute()))")
                }
            }
            .navigationTitle("Statistics")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MusicStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        MusicStatisticsView(library: MusaeManager())
    }
}
