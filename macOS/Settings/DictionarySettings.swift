import SwiftUI

struct DictionarySettings: View {
    @Environment(\.requestReview) var requestReview

    var body: some View {
        Form {
            Button {
                requestReview()
            } label: {
                Text("Review the app")
            }
        }
        .frame(width: 300)
        .navigationTitle("Landmark Settings")
        .padding(80)
    }
}

#Preview {
    DictionarySettings()
}
