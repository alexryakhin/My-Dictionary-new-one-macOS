//
//  My_DictionaryApp.swift
//  Shared
//
//  Created by Alexander Bonney on 10/6/21.
//

import SwiftUI

@main
struct My_DictionaryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        #if os(macOS)
        .windowStyle(HiddenTitleBarWindowStyle())
        #endif
    }
}
