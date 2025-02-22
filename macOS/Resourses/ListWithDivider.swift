//
//  ListWithDivider.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 2/22/25.
//

import SwiftUI

/// Has a built-in divider between each element, except the last element.
public struct ListWithDivider<
    Data: RandomAccessCollection,
    Content: View
>: View {

    private let data: Data
    private let content: (Data.Element) -> Content
    private let dividerLeadingPadding: CGFloat

    public init(
        _ data: Data,
        @ViewBuilder content: @escaping (Data.Element) -> Content,
        dividerLeadingPadding: CGFloat = 16
    ) {
        self.data = data
        self.content = content
        self.dividerLeadingPadding = dividerLeadingPadding
    }

    public var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                let lastIndex = data.count - 1
                VStack(spacing: 0) {
                    content(item)
                        .id(index)
                    if index != lastIndex {
                        Divider()
                            .padding(.leading, dividerLeadingPadding)
                    }
                }
            }
        }
    }
}
