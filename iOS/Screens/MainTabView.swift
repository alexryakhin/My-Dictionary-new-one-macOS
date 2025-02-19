import SwiftUI
import SwiftUIHandyTools

struct MainTabView: View {
    @AppStorage(UDKeys.isShowingOnboarding) var isShowingOnboarding: Bool = true

    @StateObject private var wordsViewModel = WordsViewModel()
    @StateObject private var quizzesViewModel = QuizzesViewModel()
    @StateObject private var idiomsViewModel = IdiomsViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()

    @State private var selectedItem: TabBarItem = .words

    var tabs: [TabBarItem] {
        settingsViewModel.isShowingIdioms
        ? TabBarItem.allCases
        : [.words, .quizzes, .settings]
    }

    var body: some View {
        TabBar(selection: $selectedItem) {
            ForEach(tabs, id: \.self) { tab in
                tabView(for: tab)
                    .tabItem(for: tab)
            }
        }
        .animation(.default, value: settingsViewModel.isShowingIdioms)
        .sheet(isPresented: $isShowingOnboarding, onDismiss: {
            isShowingOnboarding = false
        }, content: {
            OnboardingView()
        })
    }

    @ViewBuilder 
    func tabView(for item: TabBarItem) -> some View {
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
