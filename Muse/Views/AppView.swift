import SwiftUI

struct AppView: View {
    @State var model = MuseModel()

    var body: some View {
        if model.authorizationStatus == .authorized {
            Button("Update", action: {
                model.update()
            })
        } else {
            Button("Authorize", action: {
                model.requestAuthorization()
            })
        }
    }
}

#Preview {
    AppView()
}
