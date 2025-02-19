import SwiftUI
import Combine

final class SpellingQuizViewModel: ObservableObject {
    @Published var words: [Word] = []

    private let wordsProvider: WordsProviderInterface
    private var cancellables: Set<AnyCancellable> = []

    init(wordsProvider: WordsProviderInterface) {
        self.wordsProvider = wordsProvider
        setupBindings()
    }

    /// Fetches latest data from Core Data
    private func setupBindings() {
        wordsProvider.wordsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.words, on: self)
            .store(in: &cancellables)
    }
}

struct SpellingQuizView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: SpellingQuizViewModel

    @State private var randomWord: Word?
    @State private var answerTextField = ""
    @State private var isRightAnswer = true
    @State private var attemptCount = 0
    @State private var isShowAlert = false

    @State private var playingWords: [Word] = []

    init(viewModel: SpellingQuizViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            Section {
                Text(randomWord?.definition ?? "Error")
            } header: {
                Text("Definition")
            } footer: {
                Text("Guess the word and then spell it correctly in a text field below")
            }

            Section {
                HStack {
                    TextField("Type here", text: $answerTextField, onCommit: {
                        withAnimation {
                            checkAnswer()
                        }
                    })
                    Spacer()
                    Text(randomWord?.partOfSpeech ?? "error").foregroundColor(.secondary)
                }
            } footer: {
                Text(isRightAnswer ? "" : incorrectMessage)
            }

            Section {
                Button {
                    withAnimation {
                        checkAnswer()
                    }
                } label: {
                    Text("Confirm answer")
                }.disabled(answerTextField.isEmpty)

            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Spelling")
        .onAppear {
            playingWords = viewModel.words
            randomWord = playingWords.randomElement()
        }
        .alert(isPresented: $isShowAlert) {
            Alert(
                title: Text("Congratulations"),
                message: Text("You got all your words!"),
                dismissButton: .default(Text("Okay")) {
                    dismiss()
                }
            )
        }
    }

    private var incorrectMessage: String {
        guard let randomWord = randomWord else {
            return ""
        }

        if attemptCount > 2 {
            return "Your word is '\(randomWord.wordItself!.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))'. Try harder :)"
        } else {
            return "Incorrect. Try again"
        }
    }

    private func checkAnswer() {
        guard let randomWord = randomWord else {
            return
        }

        guard let wordIndex = playingWords.firstIndex(where: {
            $0.id == randomWord.id
        }) else {
            return
        }

        if answerTextField.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            == randomWord.wordItself!.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
            isRightAnswer = true
            answerTextField = ""
            playingWords.remove(at: wordIndex)
            attemptCount = 0
            if !playingWords.isEmpty {
                self.randomWord = playingWords.randomElement()
            } else {
                isShowAlert = true
            }
        } else {
            isRightAnswer = false
            attemptCount += 1
        }
    }
}
