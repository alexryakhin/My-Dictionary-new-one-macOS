import SwiftUI
import Combine
import StoreKit

final class SettingsViewModel: ObservableObject {
#if canImport(UIKit)
    func requestReview() {
        // try getting current scene
        guard let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
              print("UNABLE TO GET CURRENT SCENE")
              return
        }

        // show review dialog
        SKStoreReviewController.requestReview(in: currentScene)
    }
#endif
}

