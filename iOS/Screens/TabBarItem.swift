import SwiftUI

enum TabBarItem: Hashable, CaseIterable {
    case words
    case idioms
    case quizzes

    var title: String {
        switch self {
        case .words: "Words"
        case .idioms: "Idioms"
        case .quizzes: "Quizzes"
        }
    }

    var image: String {
        switch self {
        case .words: "textformat.abc"
        case .idioms: "scroll"
        case .quizzes: "a.magnify"
        }
    }
}
