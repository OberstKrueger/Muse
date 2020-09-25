import SwiftUI

struct MusicDailyView: View {
    @ObservedObject var library: MusicLibrary

    var body: some View {
        Text("MusicDailyView")
    }
}

struct MusicDailyView_Previews: PreviewProvider {
    static var previews: some View {
        MusicDailyView(library: MusicLibrary())
    }
}
