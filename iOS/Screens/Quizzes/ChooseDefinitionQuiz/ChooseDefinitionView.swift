import SwiftUI
import Combine

final class ChooseDefinitionViewModel: ObservableObject {
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

struct ChooseDefinitionView: View {
    @StateObject private var viewModel: ChooseDefinitionViewModel
    @State private var rightAnswerIndex = Int.random(in: 0...2)
    @State private var isRightAnswer = true

    init(viewModel: ChooseDefinitionViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        if !viewModel.words.isEmpty {
            List {
                Section {
                    HStack {
                        Text(viewModel.words[rightAnswerIndex].wordItself ?? "")
                            .bold()
                        Spacer()
                        Text(viewModel.words[rightAnswerIndex].partOfSpeech ?? "")
                            .foregroundColor(.secondary)
                    }

                } header: {
                    Text("Given word")
                } footer: {
                    Text("Choose from given definitions below")
                }

                Section {
                    ForEach(0..<3) { index in
                        Button {
                            if viewModel.words[rightAnswerIndex].id == viewModel.words[index].id {
                                withAnimation {
                                    isRightAnswer = true
                                    viewModel.words.shuffle()
                                    rightAnswerIndex = Int.random(in: 0...2)
                                }
                            } else {
                                withAnimation {
                                    isRightAnswer = false
                                }
                            }
                        } label: {
                            Text(viewModel.words[index].definition ?? "")
                                .foregroundColor(.primary)
                        }
                    }
                } footer: {
                    Text(isRightAnswer ? "" : "Incorrect. Try Arain")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Choose Definition")
            .onAppear {
                rightAnswerIndex = Int.random(in: 0...2)
            }
        }
    }
}
