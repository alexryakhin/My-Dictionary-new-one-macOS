//
//  WordsListCellView.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 2/21/25.
//

import SwiftUI

struct WordsListCellView: View {
    var model: Model

    var body: some View {
        HStack(spacing: 8) {
            Text(model.word)
                .bold()
                .foregroundColor(model.foregroundColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            if model.isFavorite {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundColor(model.foregroundAccentColor)
            }
            Text(model.partOfSpeech)
                .foregroundColor(model.foregroundSecondaryColor)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(model.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture(perform: model.onTap)
    }

    struct Model {
        let word: String
        let partOfSpeech: String
        let isFavorite: Bool
        let isSelected: Bool
        let onTap: () -> Void

        var backgroundColor: Color {
            isSelected ? .accentColor.opacity(0.8) : .white.opacity(0.01)
        }

        var foregroundColor: Color {
            isSelected ? .white : .primary
        }

        var foregroundAccentColor: Color {
            isSelected ? .white : .accentColor
        }

        var foregroundSecondaryColor: Color {
            isSelected ? .white : .secondary
        }
    }
}
