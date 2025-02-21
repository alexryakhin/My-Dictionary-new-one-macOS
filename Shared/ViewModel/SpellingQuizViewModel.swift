//
//  SpellingQuizViewModel.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 2/21/25.
//

import SwiftUI
import Combine

final class SpellingQuizViewModel: ObservableObject {
    @Published var words: [Word] = []

    @Published var randomWord: Word?
    @Published var answerTextField = ""
    @Published var isCorrectAnswer = true
    @Published var attemptCount = 0

    private let wordsProvider: WordsProviderInterface
    private var cancellables: Set<AnyCancellable> = []

    init(wordsProvider: WordsProviderInterface) {
        self.wordsProvider = wordsProvider
        setupBindings()
    }

    func confirmAnswer() {
        guard let randomWord,
              let wordIndex = words.firstIndex(where: { $0.id == randomWord.id })
        else { return }

        if answerTextField.trimmed == randomWord.wordItself!.trimmed {
            isCorrectAnswer = true
            answerTextField = ""
            words.remove(at: wordIndex)
            attemptCount = 0
            if !words.isEmpty {
                self.randomWord = words.randomElement()
            } else {
                self.randomWord = nil
            }
        } else {
            isCorrectAnswer = false
            attemptCount += 1
        }
    }

    /// Fetches latest data from Core Data
    private func setupBindings() {
        wordsProvider.wordsPublisher
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] words in
                self?.words = words
                self?.randomWord = words.randomElement()
            }
            .store(in: &cancellables)
    }
}
