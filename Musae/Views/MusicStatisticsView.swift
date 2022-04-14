import SwiftUI

struct MusicStatisticsView: View {
    var categories: [Category]
    var updated: Date?

    var body: some View {
        NavigationView {
            Form {
                if emptyPlaylists.count > 0 {
                    Section(header: Text("Empty Playlists")) {
                        ForEach(emptyPlaylists, id: \.self) { playlist in
                            Text(playlist)
                        }
                    }
                }

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
                if let date = updated {
                    Text("Updated: \(date.formatted(.dateTime.year().month(.wide).day().hour().minute()))")
                }
            }
            .navigationTitle("Statistics")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

extension MusicStatisticsView {
    var emptyPlaylists: [String] {
        var results: [String] = []

        for category in categories {
            for playlist in category.emptyPlaylists {
                results.append("\(category.title) - \(playlist.title)")
            }
        }

        return results.sorted()
    }

    var smallPlaylists: [String] {
        var results: [String] = []

        for category in categories {
            for playlist in category.shortPlaylists {
                results.append("\(category.title) - \(playlist.title)")
            }
        }

        return results.sorted()
    }

    var unplayedPlaylists: [(String, UInt)] {
        var results: [(String, UInt)] = []

        for category in categories {
            for playlist in category.unplayedPlaylists {
                results.append(("\(category.title) - \(playlist.title)", playlist.unplayed))
            }
        }

        return results.sorted(by: {$0.0 < $1.0})
    }
}

struct MusicStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        MusicStatisticsView(categories: [], updated: Date())
    }
}
