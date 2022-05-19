import SwiftUI

struct AppView: View {
    @StateObject var authorizer = AuthorizationManager()

    var body: some View {
        if authorizer.status == .authorized {
            MainView()
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
