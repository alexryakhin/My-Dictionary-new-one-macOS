import SwiftUI

struct SpellingQuizView: View {
    @StateObject private var viewModel: SpellingQuizViewModel

    private var incorrectMessage: String {
        guard let randomWord = viewModel.randomWord else { return "" }

        if viewModel.attemptCount > 2 {
            return "Your word is '\(randomWord.wordItself!.trimmed)'. Try harder :)"
        } else {
            return "Incorrect. Try again"
        }
    }

    init(viewModel: SpellingQuizViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            Spacer().frame(height: 100)

            Text(viewModel.randomWord?.definition ?? "Error")
                .font(.title)
                .bold()
                .padding(.horizontal, 30)
                .multilineTextAlignment(.center)

            Text(viewModel.randomWord?.partOfSpeech ?? "error")
                .foregroundColor(.secondary)

            Spacer()

            VStack {
                Text("Guess the word and then spell it correctly in a text field below")
                    .foregroundColor(.secondary).font(.caption)

                HStack {
                    TextField("Answer", text: $viewModel.answerTextField, onCommit: {
                        viewModel.confirmAnswer()
                    })
                    .frame(maxWidth: 300)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.primary.opacity(0.15))
                .cornerRadius(8)
                .padding(.horizontal, 20)
            }
            Text(viewModel.isCorrectAnswer ? "" : incorrectMessage)

            Button {
                viewModel.confirmAnswer()
            } label: {
                Text("Confirm answer")
            }
            .disabled(viewModel.answerTextField.isEmpty)

            Spacer().frame(height: 100)

        }
        .navigationTitle("Spelling")
    }
}
