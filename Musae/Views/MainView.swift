import SwiftUI

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var library = MusaeManager()

    var body: some View {
        TabView {
            MusicDailyView(library: library)
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Daily")
                }
            MusicPlaylistsView(library: library)
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Playlists")
                }
            MusicStatisticsView(library: library)
                .tabItem {
                    Image(systemName: "tablecells")
                    Text("Statistics")
                }
        }
        .onChange(of: scenePhase) { phase in
            print("scenePhase: \(phase)")
            switch phase {
            case .active:
                library.startTimer()
            case .inactive:
                library.stopTimer()
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
