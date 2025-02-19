import SwiftUI
import Swinject
import SwinjectAutoregistration

@main
struct MyDictionaryApp: App {

    let resolver: Resolver

    init() {
        resolver = DIContainer.shared.resolver

        DIContainer.shared.assemble(assembly: ServiceAssembly())
        DIContainer.shared.assemble(assembly: UIAssembly())
    }

    var body: some Scene {
        WindowGroup {
            (resolver ~> MainTabView.self)
                .font(.system(.body, design: .rounded))
        }
        #if os(macOS)
        .windowStyle(TitleBarWindowStyle())
        .windowToolbarStyle(.unifiedCompact)
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
