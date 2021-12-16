import SwiftUI

struct MusicDailyView: View {
    @ObservedObject var library: MusaeManager

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
                                player.play(library.playlistByName(category: key, name: value)!)
                            }
                            Button("Up Next") {
                                player.upNext(library.playlistByName(category: key, name: value)!, 30)
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
        MusicDailyView(library: MusaeManager())
    }
}
