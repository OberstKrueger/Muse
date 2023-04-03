import SwiftUI

struct MusicDailyView: View {
    var daily: DailyPlaylists
    var player: PlayerManager

    var body: some View {
        NavigationView {
            ScrollView { [self] in
                ForEach(daily.playlists.sorted(by: {$0.key < $1.key}), id: \.key) { category, playlist in
                    MusicDailyItemView(category: category, player: player, playlist: playlist)
                }
                if daily.playlists.count > 0 {
                    Text("Last updated: \(daily.date.formatted(.dateTime.year().month().day().weekday(.wide)))")
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
    var category: String
    var player: PlayerManager
    var playlist: Playlist

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(category)
                    .font(.headline)
                Text(playlist.title)
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            .padding()
            Spacer()
            HStack {
                Button {
                    Task { await player.play(playlist) }

                } label: {
                    Image(systemName: "play")
                }
                Button {
                    Task {
                        await player.upNext(playlist)
                    }
                } label: {
                    Image(systemName: "list.bullet")
                }
                .padding(.leading)
                Button {
                    Task {
                        await player.random(playlist)
                    }
                } label: {
                    Image(systemName: "dice")
                }
                .padding(.leading)
            }
            .padding()
        }
    }
}

struct MusicDailyView_Previews: PreviewProvider {
    static var previews: some View {
        MusicDailyView(daily: DailyPlaylists(), player: PlayerManager())
    }
}
