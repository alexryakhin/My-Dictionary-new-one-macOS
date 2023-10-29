import SwiftUI

struct MainTabView: View {
    @AppStorage(UDKeys.isShowingOnboarding) var isShowingOnboarding: Bool = true

    @StateObject private var wordsViewModel = WordsViewModel()
    @StateObject private var quizzesViewModel = QuizzesViewModel()
    @StateObject private var idiomsViewModel = IdiomsViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()

    @State private var selectedItem: TabBarItem = .words

    var body: some View {
        TabView(selection: $selectedItem) {
            ForEach(TabBarItem.allCases, id: \.self) { tab in
                tabView(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.image)
                    }
                    .tag(tab)
            }
        }
        .sheet(isPresented: $isShowingOnboarding, onDismiss: {
            isShowingOnboarding = false
        }, content: {
            OnboardingView()
        })
    }

    @ViewBuilder func tabView(for item: TabBarItem) -> some View {
        switch item {
        case .words:
            WordsListView(wordsViewModel: wordsViewModel)
        case .idioms:
            IdiomsListView(idiomsViewModel: idiomsViewModel)
        case .quizzes:
            QuizzesView(quizzesViewModel: quizzesViewModel)
        case .settings:
            SettingsView(settingsViewModel: settingsViewModel)
        }
    }
}

#Preview {
    MainTabView()
}
