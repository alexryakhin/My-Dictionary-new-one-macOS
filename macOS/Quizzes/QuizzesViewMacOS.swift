import SwiftUI
import Swinject
import SwinjectAutoregistration

struct QuizzesView: View {
    private let resolver = DIContainer.shared.resolver
    @StateObject private var viewModel: QuizzesViewModel

    init(viewModel: QuizzesViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.words.count < 10 {
                if #available(macOS 14.0, *) {
                    ContentUnavailableView {
                        Text("Add at least 10 words to your list to play!")
                    }
                } else {
                    Spacer()
                    Text("Add at least 10 words\nto your list to play!")
                        .lineSpacing(10)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    Spacer()
                }
            } else {
                List(Quiz.allCases) { quiz in
                    NavigationLink(destination: quizView(for: quiz)) {
                        Text(quiz.title)
                            .padding(.vertical, 8)
                    }
                }
                .font(.title3)
            }
        }
        .navigationTitle("Quizzes")
    }

    @ViewBuilder
    func quizView(for quiz: Quiz) -> some View {
        switch quiz {
        case .spelling:
            resolver ~> SpellingQuizView.self
        case .chooseDefinitions:
            resolver ~> ChooseDefinitionView.self
        }
    }
}

#Preview {
    DIContainer.shared.resolver ~> QuizzesView.self
}
