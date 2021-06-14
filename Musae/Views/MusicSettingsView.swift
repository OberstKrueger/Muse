import SwiftUI

struct MusicSettingsView: View {
    @EnvironmentObject var settings: MusicSettings
    @ObservedObject var library: LibraryManager

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Sort By Average Play Count", isOn: $settings.sortByAveragePlayCount)
                    Stepper("Up Next Minutes: \(settings.upNextMinutes)", value: $settings.upNextMinutes)
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
        MusicSettingsView(library: LibraryManager()).environmentObject(MusicSettings())
    }
}
