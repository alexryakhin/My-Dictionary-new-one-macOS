import SwiftUI
import SwiftUIHandyTools
import Swinject
import SwinjectAutoregistration

struct MainTabView: View {
    @AppStorage(UDKeys.isShowingOnboarding) var isShowingOnboarding: Bool = true
    @AppStorage(UDKeys.isShowingIdioms) var isShowingIdioms: Bool = false
    @State private var selectedItem: TabBarItem = .words
    private let resolver = DIContainer.shared.resolver

    var tabs: [TabBarItem] {
        isShowingIdioms
        ? TabBarItem.allCases
        : [.words, .quizzes, .settings]
    }

    var body: some View {
        TabView {
            ForEach(tabs, id: \.self) { tab in
                tabView(for: tab)
                    .tabItem {
                        Label {
                            Text(tab.title)
                        } icon: {
                            Image(systemName: tab.icon)
                        }
                    }
            }
        }
        .sheet(isPresented: $isShowingOnboarding, onDismiss: {
            isShowingOnboarding = false
        }, content: {
            resolver ~> OnboardingView.self
        })
    }

    @ViewBuilder 
    func tabView(for item: TabBarItem) -> some View {
        switch item {
        case .words:
            resolver ~> WordsListView.self
        case .idioms:
            resolver ~> IdiomsListView.self
        case .quizzes:
            resolver ~> QuizzesView.self
        case .settings:
            resolver ~> SettingsView.self
        }
    }
}

#Preview {
    DIContainer.shared.resolver ~> MainTabView.self
}
