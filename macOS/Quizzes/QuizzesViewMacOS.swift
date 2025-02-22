import SwiftUI
import Swinject
import SwinjectAutoregistration

struct QuizzesView: View {
    private let resolver = DIContainer.shared.resolver
    @Binding private var selectedQuiz: Quiz?
    @StateObject private var viewModel: QuizzesViewModel

    init(
        selectedQuiz: Binding<Quiz?>,
        viewModel: QuizzesViewModel
    ) {
        self._selectedQuiz = selectedQuiz
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
                ScrollView(showsIndicators: false) {
                    ListWithDivider(Quiz.allCases) { quiz in
                        QuizzesListCellView(
                            model: .init(
                                text: quiz.title,
                                isSelected: selectedQuiz == quiz
                            ) {
                                selectedQuiz = quiz
                            }
                        )
                    }
                }
            }
        }
        .navigationTitle("Quizzes")
        .onDisappear {
            selectedQuiz = nil
        }
    }
}

#Preview {
    DIContainer.shared.resolver ~> QuizzesView.self
}
