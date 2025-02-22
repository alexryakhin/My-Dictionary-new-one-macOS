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
        NavigationStack {
            List {
                Section {
                    ForEach(Quiz.allCases) { quiz in
                        NavigationLink {
                            quizView(for: quiz)
                        } label: {
                            Text(quiz.title)
                        }
                    }
                } footer: {
                    Text("All words are from your list.")
                }
            }
            .listStyle(.insetGrouped)
            .overlay {
                if viewModel.words.count < 10 {
                    EmptyListView(
                        label: "No words in your list",
                        description: "Add at least 10 words to your list to play!"
                    )
                }
            }
            .navigationTitle("Quizzes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                }
            }
        }
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
