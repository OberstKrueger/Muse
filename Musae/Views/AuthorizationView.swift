import MediaPlayer
import SwiftUI

struct AuthorizationView
: View {
    @ObservedObject var authorizer: AuthorizationMachine

    var body: some View {
        VStack {
            switch authorizer.status {
            case .authorized:
                Text("How did you get here?")
            case .denied:
                Text("Authorization to the music library is needed.")
                    .padding()
                Text("Music library access denied.")
                    .padding()
            case .initializing:
                Text("")
            case .unknown:
                Text("Authorization to the music library is needed.")
                    .padding()
                Button("Request Authorization") {
                    let _ = authorizer.enter(AuthorizationRequestingState.self)
                }
            }
        }
    }
}

struct AuthorizationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizationView(authorizer: AuthorizationMachine())
    }
}
