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
    @Published var isEditingDefinition = false
    @Published var isShowAddExample = false
    @Published var exampleTextFieldStr = ""

    var examples: [String] {
        guard let data = word.examples else { return [] }
        guard let examples = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return examples
    }

    private let coreDataContainer: CoreDataContainerInterface
    private let wordsProvider: WordsProviderInterface
    private let speechSynthesizer: SpeechSynthesizerInterface

    init(
        word: Word,
        coreDataContainer: CoreDataContainerInterface,
        wordsProvider: WordsProviderInterface,
        speechSynthesizer: SpeechSynthesizerInterface
    ) {
        self.word = word
        self.coreDataContainer = coreDataContainer
        self.wordsProvider = wordsProvider
        self.speechSynthesizer = speechSynthesizer
    }

    func removeExample(offsets: IndexSet) {
        var examples = self.examples
        examples.remove(atOffsets: offsets)

        let newExamplesData = try? JSONEncoder().encode(examples)
        word.examples = newExamplesData
        save()
    }

    func saveExample() {
        isShowAddExample = false
        if exampleTextFieldStr != "" {
            let newExamples = examples + [exampleTextFieldStr]
            let newExamplesData = try? JSONEncoder().encode(newExamples)
            word.examples = newExamplesData
            save()
        }
        exampleTextFieldStr = ""
    }

    func speak(_ text: String?) {
        if let text {
            speechSynthesizer.speak(text)
        }
    }

    func changePartOfSpeech(_ partOfSpeech: String) {
        word.partOfSpeech = partOfSpeech
        save()
    }

    func deleteCurrentWord() {
        wordsProvider.delete(word: word)
    }

    func save() {
        do {
            try coreDataContainer.viewContext.save()
        } catch {
            print(error.localizedDescription)
            // TODO: show snack
        }
    }
}
