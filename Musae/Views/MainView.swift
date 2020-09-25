import SwiftUI

struct MainView: View {
    @ObservedObject var library = MusicLibrary()

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
