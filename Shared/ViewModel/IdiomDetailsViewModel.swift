import Foundation
import SwiftUI
import Combine
import CoreData

final class IdiomDetailsViewModel: ObservableObject {

    @Published var idiom: Idiom
    @Published var isShowAddExample = false
    @Published var definitionTextFieldStr = ""
    @Published var exampleTextFieldStr = ""

    private let idiomsProvider: IdiomsProviderInterface
    private let speechSynthesizer: SpeechSynthesizerInterface

    private var cancellables = Set<AnyCancellable>()

    init(
        idiom: Idiom,
        idiomsProvider: IdiomsProviderInterface,
        speechSynthesizer: SpeechSynthesizerInterface
    ) {
        self.idiom = idiom
        self.idiomsProvider = idiomsProvider
        self.speechSynthesizer = speechSynthesizer
        self.definitionTextFieldStr = idiom.definition ?? ""
        setupBindings()
    }

    /// Removes selected idiom from Core Data
    func deleteCurrentIdiom() {
        idiomsProvider.deleteIdiom(idiom)
        idiomsProvider.saveContext()
    }

    func addExample() {
        do {
            try idiom.addExample(exampleTextFieldStr)
            idiomsProvider.saveContext()
            exampleTextFieldStr = ""
            isShowAddExample = false
        } catch {
            handleError(error)
        }
    }

    func removeExample(_ example: String) {
        do {
            try idiom.removeExample(example)
            idiomsProvider.saveContext()
        } catch {
            handleError(error)
        }
    }

    func removeExample(atOffsets offsets: IndexSet) {
        do {
            try idiom.removeExample(atOffsets: offsets)
            idiomsProvider.saveContext()
        } catch {
            handleError(error)
        }
    }

    func speak(_ text: String?) {
        if let text {
            speechSynthesizer.speak(text)
        }
    }

    func toggleFavorite() {
        idiom.isFavorite.toggle()
        idiomsProvider.saveContext()
    }

    private func setupBindings() {
        idiomsProvider.idiomsErrorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &cancellables)

        $definitionTextFieldStr
            .removeDuplicates()
            .debounce(for: 1, scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.idiom.definition = text
                self?.idiomsProvider.saveContext()
            }
            .store(in: &cancellables)
    }

    private func handleError(_ error: Error) {
        // TODO: show snack
        print(error.localizedDescription)
    }
}
