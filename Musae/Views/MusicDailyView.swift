import SwiftUI

struct MusicDailyView: View {
    @ObservedObject var library: MusaeManager

    var player = PlayerManager()

    var body: some View {
        NavigationView {
            ScrollView { [self] in
                ForEach(library.daily.playlists.sorted(by: {$0.key < $1.key}), id: \.key) { key, value in
                    MusicDailyItemView(library: library, key: key, player: player, value: value)
                }
                if library.daily.playlists.count > 0 {
                    Text("Last updated: \(library.daily.date.formatted(.dateTime.year().month().day().weekday(.wide)))")
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
            }
            .navigationTitle("Daily Playlists")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MusicDailyItemView: View {
    var library: MusaeManager
    var key: String
    var player: PlayerManager
    var value: Playlist

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(key)
                    .font(.headline)
                Text(value.title)
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            .padding()
            Spacer()
            HStack {
                Button("Play") {
                    player.play(value)
                }
                Button("Up Next") {
                    player.upNext(value, 30)
                }
                .padding(.leading)
            }
            .padding()
        }
    }
}

struct MusicDailyView_Previews: PreviewProvider {
    static var previews: some View {
        MusicDailyView(library: MusaeManager())
    }
}
