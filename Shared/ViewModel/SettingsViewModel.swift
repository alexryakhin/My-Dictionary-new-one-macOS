import SwiftUI
import Combine
import StoreKit

final class SettingsViewModel: ObservableObject {
    @AppStorage(UDKeys.isShowingRating) var isShowingRating: Bool = true
    @AppStorage(UDKeys.isShowingIdioms) var isShowingIdioms: Bool = false
}

