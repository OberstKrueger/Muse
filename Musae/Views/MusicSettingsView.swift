import SwiftUI

struct MusicSettingsView: View {
    @EnvironmentObject var settings: MusicSettings

    var body: some View {
        Text("MusicSettingsView")
    }
}

struct MusicSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MusicSettingsView().environmentObject(MusicSettings())
    }
}
