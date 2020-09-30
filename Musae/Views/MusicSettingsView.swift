import SwiftUI

struct MusicSettingsView: View {
    @EnvironmentObject var settings: MusicSettings

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Sort By Average Play Count", isOn: $settings.sortByAveragePlayCount)
                    Stepper("Up Next Minutes: \(settings.upNextMinutes)", value: $settings.upNextMinutes)
                }
            }
            .navigationTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MusicSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MusicSettingsView().environmentObject(MusicSettings())
    }
}
