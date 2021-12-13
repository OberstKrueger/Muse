import SwiftUI

struct MusicSettingsView: View {
    @EnvironmentObject var settings: MusicSettings
    @ObservedObject var library: MusaeManager

    var smallPlaylists: [String] {
        var results: [String] = []

        for (category, playlists) in library.categories {
            for playlist in playlists {
                if Int(playlist.length) < settings.upNextMinutes {
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
                Section {
                    Toggle("Sort By Average Play Count", isOn: $settings.sortByAveragePlayCount)
                    Stepper("Up Next Minutes: \(settings.upNextMinutes)", value: $settings.upNextMinutes)
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
                if let date = library.lastUpdated {
                    Text("Library Updated: \(date)")
                }
            }
            .navigationTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MusicSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MusicSettingsView(library: MusaeManager()).environmentObject(MusicSettings())
    }
}
