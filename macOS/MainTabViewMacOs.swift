//
//  MainTabViewMacOs.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Bonney on 10/7/21.
//

import SwiftUI

var screen = NSScreen.main!.visibleFrame

struct MainTabView: View {
    @StateObject var homeData = HomeViewModel()
    
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                TabButton(image: "textformat.abc", title: "Words", selectedTab: $homeData.selectedTab)
                TabButton(image: "a.magnify", title: "Quizzes", selectedTab: $homeData.selectedTab)
                Spacer()
                TabButton(image: "gear", title: "Settings", selectedTab: $homeData.selectedTab)
            }
            .padding()
            .padding(.top, 40)
            .background(BlurView())
            

            ZStack{
                switch homeData.selectedTab{
                case "Words": NavigationView{ WordsListView() }
                case "Quizzes": Text("Quizzes")
                case "Settings": Text("Settings")
                default : Text("Select an item")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.none)
        }
        .ignoresSafeArea(.container, edges: .all)
        .frame(minWidth: 800, minHeight: 600)
        .environmentObject(homeData)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
