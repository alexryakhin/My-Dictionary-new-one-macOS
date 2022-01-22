//
//  My_DictionaryApp.swift
//  Shared
//
//  Created by Alexander Bonney on 10/6/21.
//

import SwiftUI

@main
struct My_DictionaryApp: App {
    @StateObject var persistenceController = PersistenceController()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(persistenceController)
                .font(.system(.body, design: .rounded))
        }
        #if os(macOS)
        .windowStyle(HiddenTitleBarWindowStyle())
        #endif
    }
}
