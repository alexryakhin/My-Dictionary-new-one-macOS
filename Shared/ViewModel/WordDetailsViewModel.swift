//
//  WordDetailsViewModel.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 2/19/25.
//

import Combine
import Foundation

final class WordDetailsViewModel: ObservableObject {
    @Published var word: Word
    @Published var isShowAddExample = false
    @Published var definitionTextFieldStr = ""
    @Published var exampleTextFieldStr = ""

    private let wordsProvider: WordsProviderInterface
    private let speechSynthesizer: SpeechSynthesizerInterface
    private var cancellables: Set<AnyCancellable> = []

    init(
        word: Word,
        wordsProvider: WordsProviderInterface,
        speechSynthesizer: SpeechSynthesizerInterface
    ) {
        self.word = word
        self.wordsProvider = wordsProvider
        self.speechSynthesizer = speechSynthesizer
        self.definitionTextFieldStr = word.definition ?? ""
        setupBindings()
    }

    func removeExample(_ example: String) {
        do {
            try word.removeExample(example)
            wordsProvider.saveContext()
        } catch {
            handleError(error)
        }
    }

    func removeExample(atOffsets offsets: IndexSet) {
        do {
            try word.removeExample(atOffsets: offsets)
            wordsProvider.saveContext()
        } catch {
            handleError(error)
        }
    }

    func saveExample() {
        do {
            try word.addExample(exampleTextFieldStr)
            wordsProvider.saveContext()
            exampleTextFieldStr = ""
            isShowAddExample = false
        } catch {
            handleError(error)
        }
    }

    func speak(_ text: String?) {
        if let text {
            speechSynthesizer.speak(text)
        }
    }

    func changePartOfSpeech(_ partOfSpeech: String) {
        word.partOfSpeech = partOfSpeech
        wordsProvider.saveContext()
    }

    func deleteCurrentWord() {
        wordsProvider.delete(word: word)
        wordsProvider.saveContext()
    }

    func toggleFavorite() {
        word.isFavorite.toggle()
        wordsProvider.saveContext()
    }

    private func setupBindings() {
        wordsProvider.wordsErrorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &cancellables)

        $definitionTextFieldStr
            .removeDuplicates()
            .debounce(for: 1, scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.word.definition = text
                self?.wordsProvider.saveContext()
            }
            .store(in: &cancellables)
    }

    private func handleError(_ error: Error) {
        // TODO: show snack
        print(error.localizedDescription)
    }
}
