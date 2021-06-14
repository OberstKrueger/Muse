import SwiftUI

struct MusicDailyView: View {
    @EnvironmentObject var settings: MusicSettings
    @ObservedObject var library: LibraryManager

    var player = PlayerManager()

    var body: some View {
        NavigationView {
            ScrollView { [self] in
                ForEach(library.daily.playlists.sorted(by: {$0.key < $1.key}), id: \.key) { key, value in
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
                                player.play()
                            }
                            Button("Up Next") {
                                player.upNext()
                            }
                            .padding(.leading)
                        }
                        .padding()
                    }
                }
                if let date = library.daily.date {
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
        MusicDailyView(library: LibraryManager()).environmentObject(MusicSettings())
    }
}
