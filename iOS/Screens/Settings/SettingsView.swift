import SwiftUI
import Swinject
import SwinjectAutoregistration

struct SettingsView: View {
    @Environment(\.requestReview) var requestReview
    @StateObject private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Review section

                if viewModel.isShowingRating {
                    Section {
                        Button {
                            requestReview()
                        } label: {
                            Label {
                                Text("Rate the app")
                            } icon: {
                                Image(systemName: "star.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(Color.yellow)
                            }
                        }
                    }
                }

                // MARK: - Idioms Tab

                Section {
                    Toggle(isOn: $viewModel.isShowingIdioms, label: {
                        Text("Showing Idioms Tab")
                    })
                }

                // MARK: - Export

                Section {
                    Text("Export")
                }
            }
            .navigationTitle("Settings")
            .listStyle(.insetGrouped)
        }
    }
}

#Preview {
    DIContainer.shared.resolver ~> SettingsView.self
}
