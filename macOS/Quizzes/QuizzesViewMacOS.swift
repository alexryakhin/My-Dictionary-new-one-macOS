import SwiftUI

struct QuizzesView: View {
    @ObservedObject private var viewModel: QuizzesViewModel

    init(viewModel: QuizzesViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.words.count < 10 {
                Spacer()
                Text("Add at least 10 words\nto your list to play!")
                    .lineSpacing(10)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                Spacer()
            } else {
                List(Quiz.allCases, id: \.self, selection: $viewModel.selectedQuiz) { quiz in
                    NavigationLink(destination: quizView(for: quiz)) {
                        Text(quiz.title)
                            .padding(.vertical, 8)
                    }
                }
                .font(.title3)
            }
        }
        .navigationTitle("Quizzes")
        .onAppear {
            viewModel.fetchWords()
        }
    }

    @ViewBuilder func quizView(for quiz: Quiz) -> some View {
        switch quiz {
        case .spelling:
            SpellingQuizView(viewModel: viewModel)
        case .chooseDefinitions:
            ChooseDefinitionView(viewModel: viewModel)
        }
    }
}

#Preview {
    QuizzesView(viewModel: QuizzesViewModel())
}
