import Foundation
import SwiftUI
import Combine
import CoreData

final class IdiomDetailsViewModel: ObservableObject {

    @Published var idiom: Idiom
    @Published var isEditingDefinition = false
    @Published var isShowAddExample = false
    @Published var exampleTextFieldStr = ""

    var examples: [String] {
        guard let data = idiom.examples,
              let examples = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return examples
    }

    private let coreDataContainer: CoreDataContainerInterface
    private let idiomsProvider: IdiomsProviderInterface
    private let speechSynthesizer: SpeechSynthesizerInterface

    private var cancellables = Set<AnyCancellable>()

    init(
        idiom: Idiom,
        coreDataContainer: CoreDataContainerInterface,
        idiomsProvider: IdiomsProviderInterface,
        speechSynthesizer: SpeechSynthesizerInterface
    ) {
        self.idiom = idiom
        self.coreDataContainer = coreDataContainer
        self.idiomsProvider = idiomsProvider
        self.speechSynthesizer = speechSynthesizer
    }

    /// Removes selected idiom from Core Data
    func deleteCurrentIdiom() {
        idiomsProvider.deleteIdiom(idiom)
    }

    func addExample() {
        isShowAddExample = false
        if exampleTextFieldStr != "" {
            let newExamples = examples + [exampleTextFieldStr]
            let newExamplesData = try? JSONEncoder().encode(newExamples)
            idiom.examples = newExamplesData
            save()
        }
        exampleTextFieldStr = ""
    }

    func removeExample(offsets: IndexSet) {
        var examples = examples
        examples.remove(atOffsets: offsets)
        let newExamplesData = try? JSONEncoder().encode(examples)
        idiom.examples = newExamplesData
        save()
    }

    func speak(_ text: String?) {
        if let text {
            speechSynthesizer.speak(text)
        }
    }

    func save() {
        do {
            try coreDataContainer.viewContext.save()
        } catch {
            // TODO: show error
            print(error.localizedDescription)
        }
    }
}
