//
//  TabButton.swift
//  MyDictionary (MacOS)
//
//  Created by Alexander Ryakhin on 6/01/21.
//

import SwiftUI

struct TabButton: View {
    var button: TabButtonCase
    @Binding var selectedTab: TabButtonCase

    var body: some View {
        Button(action: {
            withAnimation {
                selectedTab = button
            }
        }, label: {
            VStack(spacing: 7) {
                button.image
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(selectedTab == button ? .primary : .gray)

                Text(button.title)
                    .fontWeight(.semibold)
                    .font(.system(size: 11))
                    .foregroundColor(selectedTab == button ? .primary : .gray)
            }
            .padding(.vertical, 8)
            .frame(width: 70)
            .contentShape(Rectangle())
            .background(Color.primary.opacity(selectedTab == button ? 0.15 : 0))
            .cornerRadius(10)
        })
        .buttonStyle(PlainButtonStyle())
    }
    
    enum TabButtonCase: CaseIterable {
        case words
        case idioms
        case quizzes
        
        var title: String {
            switch self {
            case .words:
                return "Words"
            case .idioms:
                return "Idioms"
            case .quizzes:
                return "Quizzes"
            }
        }
        
        var image: Image {
            switch self {
            case .words:
                return Image(systemName: "textformat.abc")
            case .idioms:
                return Image(systemName: "scroll")
            case .quizzes:
                return Image(systemName: "a.magnify")
            }
        }
    }
}
