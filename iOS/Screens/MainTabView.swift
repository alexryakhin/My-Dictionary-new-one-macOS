//
//  MainTabView.swift
//  My Dictionary (iOS)
//
//  Created by Alexander Bonney on 10/7/21.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var persistenceController: PersistenceController
    @AppStorage("isShowingOnboarding") var isShowingOnboarding: Bool = true
    
    var body: some View {
        TabView {
            WordsListView()
                .tabItem {
                    Label("Words", systemImage: "textformat.abc")
                }.environmentObject(persistenceController)
            IdiomsListView()
                .tabItem {
                    Label("Idioms", systemImage: "scroll")
                }.environmentObject(persistenceController)
//            QuizesView()
//                .tabItem {
//                    Label("Quizzes", systemImage: "a.magnify")
//                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $isShowingOnboarding, onDismiss: {
            isShowingOnboarding = false
        }) {
            OnboardingView()
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

