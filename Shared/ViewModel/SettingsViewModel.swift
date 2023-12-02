import SwiftUI
import Combine
import StoreKit

final class SettingsViewModel: ObservableObject {
    var isShowingIdioms: Bool {
        get {
            UserDefaults.standard.bool(forKey: UDKeys.isShowingIdioms)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UDKeys.isShowingIdioms)
            objectWillChange.send()
        }
    }
}

