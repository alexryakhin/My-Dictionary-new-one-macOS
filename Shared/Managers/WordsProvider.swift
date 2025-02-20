import SwiftUI
import Combine
import CoreData
import Swinject
import SwinjectAutoregistration

protocol WordsProviderInterface {
    var wordsPublisher: CurrentValueSubject<[Word], Never> { get }
    var wordsErrorPublisher: PassthroughSubject<AppError, Never> { get }

    /// Creates a new word into the Core Data (does not save the data)
    func addNewWord(word: String, definition: String, partOfSpeech: String, phonetic: String?)

    /// Removes a given word from the Core Data (does not save the data)
    func delete(word: Word)

    /// Saves all changes in the Core Data
    func saveContext()
}

final class WordsProvider: WordsProviderInterface {
    private let coreDataContainer: CoreDataContainerInterface

    var wordsPublisher = CurrentValueSubject<[Word], Never>([])
    var wordsErrorPublisher = PassthroughSubject<AppError, Never>()

    private var cancellable = Set<AnyCancellable>()

    init(coreDataContainer: CoreDataContainerInterface) {
        self.coreDataContainer = coreDataContainer

        setupBindings()
        fetchWords()
    }

    // MARK: - Public methods

    func addNewWord(word: String, definition: String, partOfSpeech: String, phonetic: String?) {
        let newWord = Word(context: coreDataContainer.viewContext)
        newWord.id = UUID()
        newWord.wordItself = word
        newWord.definition = definition
        newWord.partOfSpeech = partOfSpeech
        newWord.phonetic = phonetic
        newWord.timestamp = Date()
    }

    func delete(word: Word) {
        coreDataContainer.viewContext.delete(word)
    }

    func saveContext() {
        do {
            try coreDataContainer.viewContext.save()
        } catch {
            wordsErrorPublisher.send(.coreDataError(.saveError))
        }
    }

    // MARK: - Private methods

    private func setupBindings() {
        // every time core data gets updated, call fetchWords()
        NotificationCenter.default.managedObjectContextDidMergeChangesObjectIDsPublisher
            .combineLatest(NotificationCenter.default.managedObjectContextDidSavePublisher)
            .throttle(for: 1, scheduler: RunLoop.main, latest: true)
            .sink { [weak self] _ in
                self?.fetchWords()
            }
            .store(in: &cancellable)
    }

    /// Fetches latest data from Core Data
    private func fetchWords() {
        let request = NSFetchRequest<Word>(entityName: "Word")
        do {
            let words = try coreDataContainer.viewContext.fetch(request)
            wordsPublisher.send(words)
        } catch {
            wordsErrorPublisher.send(.coreDataError(.fetchError))
        }
    }
}
