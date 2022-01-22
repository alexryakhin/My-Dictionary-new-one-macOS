//
//  My_DictionaryApp.swift
//  My Dictionary (Shared)
//
//  Created by Alexander Bonney on 10/6/21.
//

import SwiftUI

@main
struct My_DictionaryApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .font(.system(.body, design: .rounded))
        }
        #if os(macOS)
        .windowStyle(HiddenTitleBarWindowStyle())
        #endif
    }
}
