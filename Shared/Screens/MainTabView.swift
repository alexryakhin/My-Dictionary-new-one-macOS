//
//  MainTabView.swift
//  My Dictionary (iOS)
//
//  Created by Alexander Bonney on 10/7/21.
//

import SwiftUI

struct MainTabView: View {
    @State private var showingOnboarding: Bool = !CurrentUserManager.shared.hasSeenOnboarding
    
    var body: some View {
        TabView {
            WordsListView()
                .tabItem {
                    Label("Words", systemImage: "textformat.abc")
            }
//            QuizesView()
            Text("Quizzes")
                .tabItem {
                    Label("Quiz", systemImage: "a.magnify")
                }
        }
//        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingOnboarding, onDismiss: {
            CurrentUserManager.shared.hasSeenOnboarding = true
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

