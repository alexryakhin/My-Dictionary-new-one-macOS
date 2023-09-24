import SwiftUI

struct MainTabView: View {
    @AppStorage("isShowingOnboarding") var isShowingOnboarding: Bool = true

    var body: some View {
        TabView {
            WordsListView()
                .tabItem {
                    Label("Words", systemImage: "textformat.abc")
                }
            IdiomsListView()
                .tabItem {
                    Label("Idioms", systemImage: "scroll")
                }
            QuizzesView()
                .tabItem {
                    Label("Quizzes", systemImage: "a.magnify")
                }
        }
        .sheet(isPresented: $isShowingOnboarding, onDismiss: {
            isShowingOnboarding = false
        }, content: {
            OnboardingView()
        })
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
