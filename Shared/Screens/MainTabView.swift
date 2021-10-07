//
//  MainTabView.swift
//  My Dictionary (iOS)
//
//  Created by Alexander Bonney on 10/7/21.
//

import SwiftUI

struct MainTabView: View {
#if os(iOS)
    @State private var showingOnboarding: Bool = !CurrentUserManager.shared.hasSeenOnboarding
#endif
    
    var body: some View {
#if os(iOS)
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
        .sheet(isPresented: $showingOnboarding, onDismiss: {
            CurrentUserManager.shared.hasSeenOnboarding = true
        }) {
            OnboardingView()
        }
#else
        NavigationView {
            Form {
                NavigationLink(destination: WordsListView()) {
                    HStack {
                        Image(systemName: "textformat.abc").frame(width: 20, height: 20, alignment: .center)
                        Text("Words").frame(width: 50, height: 20, alignment: .leading)
                    }
                }
                NavigationLink(destination: Text("Quizzes")) {
                    HStack {
                        Image(systemName: "a.magnify").frame(width: 20, height: 20, alignment: .center)
                        Text("Quizzes").frame(width: 50, height: 20, alignment: .leading)
                    }
                }
                Spacer()
            }
            Text("Select")
        }
        
#endif
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

