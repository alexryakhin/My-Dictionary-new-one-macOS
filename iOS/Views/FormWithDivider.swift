//
//  FormWithDivider.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 2/21/25.
//

import SwiftUI

/// A custom view that mimics a Form and adds dividers between each element.
public struct FormWithDivider<Content: View>: View {

    private let content: Content
    private let dividerLeadingPadding: CGFloat

    public init(
        dividerLeadingPadding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.dividerLeadingPadding = dividerLeadingPadding
    }

    public var body: some View {
        _VariadicView.Tree(FormWithDividerLayout(dividerLeadingPadding: dividerLeadingPadding)) {
            content
        }
    }

    struct FormWithDividerLayout: _VariadicView_MultiViewRoot {
        let dividerLeadingPadding: CGFloat

        @ViewBuilder
        func body(children: _VariadicView.Children) -> some View {
            let last = children.last?.id
            LazyVStack(spacing: 0) {
                ForEach(children) { child in
                    child
                    if child.id != last {
                        Divider()
                            .padding(.leading, dividerLeadingPadding)
                    }
                }
            }
        }
    }
}
