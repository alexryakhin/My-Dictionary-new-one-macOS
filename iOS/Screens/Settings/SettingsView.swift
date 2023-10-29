import SwiftUI

struct SettingsView: View {
    @AppStorage(UDKeys.isShowingRating) var isShowingRating: Bool = true

    @Environment(\.requestReview) var requestReview

    @ObservedObject private var settingsViewModel: SettingsViewModel

    init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
    }

    var body: some View {
        NavigationStack {
            List {
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
            .navigationTitle("Settings")
            .listStyle(.insetGrouped)
        }
    }
}

#Preview {
    SettingsView(settingsViewModel: SettingsViewModel())
}
