import MediaPlayer
import SwiftUI

// Go back to doing authorizer that also requests authorization

struct AuthorizationView: View {
    @ObservedObject var authorizer: MusicAuthorizer

    var body: some View {
        VStack {
            Text("Authorization to the music library is needed.")
                .padding()
            switch authorizer.status {
            case .authorized:
                Text("How did you get here?")
            case .denied:
                Text("Denied")
            case .notAsked, .unknown:
                Button("Request Authorization") {
                    authorizer.requestAuthorization()
                }
            }
        }
    }
}

struct AuthorizationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AuthorizationView(authorizer: MusicAuthorizer(status: .authorized))
            AuthorizationView(authorizer: MusicAuthorizer(status: .denied))
            AuthorizationView(authorizer: MusicAuthorizer(status: .notAsked))
            AuthorizationView(authorizer: MusicAuthorizer(status: .unknown))
        }
    }
}
