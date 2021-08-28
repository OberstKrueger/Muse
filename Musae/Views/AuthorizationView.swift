import MediaPlayer
import SwiftUI

struct AuthorizationView: View {
    @ObservedObject var authorizer: AuthorizationManager

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
            AuthorizationView(authorizer: AuthorizationManager(status: .authorized))
            AuthorizationView(authorizer: AuthorizationManager(status: .denied))
            AuthorizationView(authorizer: AuthorizationManager(status: .notAsked))
            AuthorizationView(authorizer: AuthorizationManager(status: .unknown))
        }
    }
}
