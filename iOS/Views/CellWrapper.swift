//
//  CellWrapper.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 2/21/25.
//

import SwiftUI

public struct CellWrapper<LeadingContent: View, MainContent: View, TrailingContent: View>: View {
    @Environment(\.isEnabled) var isEnabled: Bool

    private let label: LocalizedStringKey?
    private let leadingContent: () -> LeadingContent
    private let mainContent: () -> MainContent
    private let trailingContent: () -> TrailingContent
    private let onTapAction: (() -> Void)?

    public init(
        _ label: LocalizedStringKey? = nil,
        @ViewBuilder leadingContent: @escaping () -> LeadingContent = { EmptyView() },
        @ViewBuilder mainContent: @escaping () -> MainContent,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() },
        onTapAction: (() -> Void)? = nil
    ) {
        self.label = label
        self.leadingContent = leadingContent
        self.mainContent = mainContent
        self.trailingContent = trailingContent
        self.onTapAction = onTapAction
    }

    public var body: some View {
        HStack(spacing: 12) {
            leadingContent()
            VStack(alignment: .leading, spacing: 4) {
                if let label {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                mainContent()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            trailingContent()
        }
        .ifLet(onTapAction) { view, action in
            view.onTap {
                action()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .allowsHitTesting(isEnabled)
        .opacity(isEnabled ? 1 : 0.4)
    }
}
