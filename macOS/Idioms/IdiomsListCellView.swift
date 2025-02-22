//
//  IdiomsListCellView.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 2/22/25.
//

import SwiftUI

struct IdiomsListCellView: View {
    var model: Model

    var body: some View {
        HStack {
            Text(model.idiom)
                .bold()
            Spacer()
            if model.isFavorite {
                Label {
                    EmptyView()
                } icon: {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }

    struct Model {
        let idiom: String
        let isFavorite: Bool
    }
}
