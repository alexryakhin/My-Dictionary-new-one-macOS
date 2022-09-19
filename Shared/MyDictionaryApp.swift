//
//  MyDictionaryApp.swift
//  My Dictionary (Shared)
//
//  Created by Alexander Bonney on 10/6/21.
//

import SwiftUI

@main
struct MyDictionaryApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .font(.system(.body, design: .rounded))
        }
        #if os(macOS)
        .windowStyle(HiddenTitleBarWindowStyle())
        #endif
        
        #if !os(watchOS)
        .commands {
            DictionaryCommands()
        }
        #endif
        
        #if os(macOS)
        Settings {
            DictionarySettings()
        }
        #endif
    }
}
