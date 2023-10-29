import SwiftUI

struct SettingsView: View {
    @AppStorage(UDKeys.isShowingRating) var isShowingRating: Bool = true
    @ObservedObject private var settingsViewModel: SettingsViewModel

    init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: .constant(true), label: {
                        Text("Show Idioms Tab")
                    })
                    Text("G")
                }
                if isShowingRating {
                    Section {
                        Button {
                            settingsViewModel.requestReview()
                        } label: {
                            Text("Rate the app")
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
