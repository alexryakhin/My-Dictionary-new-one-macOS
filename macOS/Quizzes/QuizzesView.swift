import SwiftUI

struct QuizzesView: View {
    @ObservedObject private var quizzesViewModel: QuizzesViewModel

    init(quizzesViewModel: QuizzesViewModel) {
        self.quizzesViewModel = quizzesViewModel
    }

    var body: some View {
        VStack(alignment: .leading) {
            if quizzesViewModel.words.count < 10 {
                Spacer()
                Text("Add at least 10 words\nto your list to play!")
                    .lineSpacing(10)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                Spacer()
            } else {
                List(Quiz.allCases, id: \.self, selection: $quizzesViewModel.selectedQuiz) { quiz in
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
            quizzesViewModel.fetchWords()
        }
    }

    @ViewBuilder func quizView(for quiz: Quiz) -> some View {
        switch quiz {
        case .spelling:
            SpellingQuizView(quizzesViewModel: quizzesViewModel)
        case .chooseDefinitions:
            ChooseDefinitionView(quizzesViewModel: quizzesViewModel)
        }
    }
}

#Preview {
    QuizzesView(quizzesViewModel: QuizzesViewModel())
}
