import SwiftUI

enum TabBarItem: CaseIterable {
    case words
    case idioms
    case quizzes
    case settings

    var title: String {
        switch self {
        case .words: "Words"
        case .idioms: "Idioms"
        case .quizzes: "Quizzes"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .words: "textformat.abc"
        case .idioms: "scroll"
        case .quizzes: "a.magnify"
        case .settings: "gearshape"
        }
    }
}
