//
//  View+Extension.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 2/21/25.
//

import SwiftUI

extension View {

    /// Removing keyboard on tap
    func editModeDisabling() -> some View {
        self
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
    }

    @ViewBuilder
    func ifLet<T, Result: View>(_ value: T?, transform: (Self, T) -> Result) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`<Result: View>(_ condition: Bool, transform: (Self) -> Result) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func onTap(_ onTap: @escaping () -> Void) -> some View {
        Button {
            onTap()
        } label: {
            self
        }
    }
}
