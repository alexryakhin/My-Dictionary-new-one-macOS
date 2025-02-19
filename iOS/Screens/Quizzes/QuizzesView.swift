import SwiftUI

struct QuizzesView: View {
    @ObservedObject private var quizzesViewModel: QuizzesViewModel

    init(quizzesViewModel: QuizzesViewModel) {
        self.quizzesViewModel = quizzesViewModel
    }

    var body: some View {
        NavigationStack {
            List(selection: $quizzesViewModel.selectedQuiz) {
                Section {
                    ForEach(Quiz.allCases, id: \.self) { quiz in
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
                if quizzesViewModel.words.count < 10 {
                    EmptyListView(text: "Add at least 10 words\nto your list to play!")
                }
            }
            .navigationTitle("Quizzes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                }
            }
            .onAppear {
                quizzesViewModel.fetchWords()
            }
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
