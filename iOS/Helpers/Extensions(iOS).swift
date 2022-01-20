//
//  Extensions(iOS).swift
//  My Dictionary (iOS)
//
//  Created by Alexander Ryakhin on 1/20/22.
//

import Foundation
import Combine
import SwiftUI
import UIKit

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for:nil)
    }
}
