import SwiftUI
import Swinject
import SwinjectAutoregistration

struct DictionarySettings: View {
    @Environment(\.requestReview) var requestReview

    @StateObject private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            Button {
                requestReview()
            } label: {
                Text("Review the app")
            }
        }
        .frame(width: 300)
        .navigationTitle("Dictionary Settings")
        .padding(80)
    }
}

#Preview {
    DIContainer.shared.resolver ~> DictionarySettings.self
}
