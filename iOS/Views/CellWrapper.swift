//
//  CellWrapper.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 2/21/25.
//

import SwiftUI

public struct CellWrapper<LeadingContent: View, MainContent: View, TrailingContent: View>: View {
    @Environment(\.isEnabled) var isEnabled: Bool

    private let leadingContent: () -> LeadingContent
    private let mainContent: () -> MainContent
    private let trailingContent: () -> TrailingContent
    private let onTapAction: (() -> Void)?

    public init(
        @ViewBuilder leadingContent: @escaping () -> LeadingContent = { EmptyView() },
        @ViewBuilder mainContent: @escaping () -> MainContent,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() },
        onTapAction: (() -> Void)? = nil
    ) {
        self.leadingContent = leadingContent
        self.mainContent = mainContent
        self.trailingContent = trailingContent
        self.onTapAction = onTapAction
    }

    public var body: some View {
        HStack(spacing: 12) {
            leadingContent()
            mainContent()
                .frame(maxWidth: .infinity, alignment: .leading)
            trailingContent()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .ifLet(onTapAction) { view, action in
            view.onTap {
                action()
            }
        }
        .allowsHitTesting(isEnabled)
        .opacity(isEnabled ? 1 : 0.4)
    }
}
