import SwiftUI
import Combine

struct SpellingQuizView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: SpellingQuizViewModel

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
        if let randomWord = viewModel.randomWord {
            List {
                Section {
                    Text(randomWord.definition ?? "Error")
                } header: {
                    Text("Definition")
                } footer: {
                    Text("Guess the word and then spell it correctly in a text field below")
                }

                Section {
                    HStack {
                        TextField("Type here", text: $viewModel.answerTextField, onCommit: {
                            withAnimation {
                                viewModel.confirmAnswer()
                            }
                        })
                        Spacer()
                        Text(randomWord.partOfSpeech ?? "error").foregroundColor(.secondary)
                    }
                } footer: {
                    Text(viewModel.isCorrectAnswer ? "" : incorrectMessage)
                }

                Section {
                    Button {
                        withAnimation {
                            viewModel.confirmAnswer()
                        }
                    } label: {
                        Text("Confirm answer")
                    }
                    .disabled(viewModel.answerTextField.isEmpty)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Spelling")
        } else {
            EmptyListView(
                label: "Congratulations!",
                description: "You got all your words!"
            )
        }
    }
}
