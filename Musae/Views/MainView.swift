import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            MusicDailyView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Daily")
                }
            MusicPlaylistsView()
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Playlists")
                }
            MusicSettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
