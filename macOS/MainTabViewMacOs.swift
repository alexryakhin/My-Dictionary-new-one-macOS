//
//  MainTabViewMacOs.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Bonney on 10/7/21.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var wordsViewModel = WordsViewModel()
    @StateObject var quizzesViewModel = QuizzesViewModel()
    @StateObject var idiomsViewModel = IdiomsViewModel()
    
    @State var selectedTab: TabButton.TabButtonCase = .words

    var body: some View {
        NavigationView {
            VStack {
                switch selectedTab {
                case .words: WordsListView().environmentObject(wordsViewModel)
                case .idioms: IdiomsListViewMacOS().environmentObject(idiomsViewModel)
                case .quizzes: QuizzesView().environmentObject(quizzesViewModel)
                }
                HStack {
                    ForEach(TabButton.TabButtonCase.allCases, id: \.self) { button in
                        TabButton(button: button, selectedTab: $selectedTab)
                    }
                }
                .padding(.bottom)
                .padding(.horizontal)
            }
            Text("Select an item")
        }
        .frame(minWidth: 700, minHeight: 300)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
