//
//  QuizzesListCellView.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 2/22/25.
//

import SwiftUI

struct QuizzesListCellView: View {
    var model: Model

    var body: some View {
        HStack(spacing: 8) {
            Text(model.text)
                .bold()
                .foregroundColor(model.foregroundColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(model.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture(perform: model.onTap)
    }

    struct Model {
        let text: String
        let isSelected: Bool
        let onTap: () -> Void

        var backgroundColor: Color {
            isSelected ? .accentColor.opacity(0.8) : .white.opacity(0.01)
        }

        var foregroundColor: Color {
            isSelected ? .white : .primary
        }
    }
}
