import SwiftUI

struct MusicDailyView: View {
    @ObservedObject var library: MusicLibrary

    var body: some View {
        NavigationView {
            ScrollView { [self] in
                ForEach(library.dailyPlaylists.sorted(by: {$0.key < $1.key}), id: \.key) { key, value in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(key)
                                .font(.headline)
                            Text(value)
                                .font(.caption)
                                .foregroundColor(Color.gray)
                        }
                        .padding()
                        Spacer()
                        HStack {
                            Button("Play") {
                                // play music
                            }
                            Button("Up Next") {
                                // add to up next
                            }
                            .padding(.leading)
                        }
                        .padding()
                    }
                }
                if let date = library.dailyPlaylistDate {
                    Button("Last updated: \(date)") {
                        library.loadDailyPlaylists(force: true)
                    }
                }
            }
            .navigationTitle("Daily Playlists")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MusicDailyView_Previews: PreviewProvider {
    static var previews: some View {
        MusicDailyView(library: MusicLibrary())
    }
}
