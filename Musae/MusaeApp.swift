import SwiftUI

@main
struct MusaeApp: App {
    var settings = MusicSettings()

    var body: some Scene {
        WindowGroup {
            AppView().environmentObject(settings)
        }
    }
}
