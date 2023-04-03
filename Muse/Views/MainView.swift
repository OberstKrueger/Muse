import SwiftUI

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var manager = MuseManager()
    var player = PlayerManager()

    var body: some View {
        TabView {
            MusicDailyView(daily: manager.daily, player: player)
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Daily")
                }
            MusicPlaylistsView(categories: manager.categories, daily: manager.daily)
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Playlists")
                }
            MusicStatisticsView(categories: manager.categories, updated: manager.lastUpdated)
                .tabItem {
                    Image(systemName: "tablecells")
                    Text("Statistics")
                }
        }
        .onChange(of: scenePhase) { phase in
            print("scenePhase: \(phase)")
            switch phase {
            case .active:
                manager.refreshTask()
            case .inactive:
                manager.stopRefreshTask()
            default:
                break
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
