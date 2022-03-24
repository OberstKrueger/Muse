import SwiftUI

struct AppView: View {
    @StateObject var authorizer = AuthorizationMachine()
    @StateObject var manager = MusaeManager()

    var body: some View {
        if authorizer.status == .authorized {
            MainView(manager: manager)
        } else {
            AuthorizationView(authorizer: authorizer)
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
