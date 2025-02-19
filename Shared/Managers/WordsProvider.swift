import SwiftUI
import Combine
import CoreData
import Swinject
import SwinjectAutoregistration

protocol WordsProviderInterface {
    var wordsPublisher: CurrentValueSubject<[Word], Never> { get }
    var wordsErrorPublisher: PassthroughSubject<AppError, Never> { get }

    func addNewWord(word: String, definition: String, partOfSpeech: String, phonetic: String?)
    func delete(word: Word)
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
        save()
    }

    /// Removes given word from Core Data
    func delete(word: Word) {
        coreDataContainer.viewContext.delete(word)
        save()
    }

    // MARK: - Private methods

    private func setupBindings() {
        // every time core data gets updated, call fetchWords()
        NotificationCenter.default.publisher(
            for: NSManagedObjectContext.didMergeChangesObjectIDsNotification,
            object: coreDataContainer.viewContext
        )
        .combineLatest(
            NotificationCenter.default.publisher(
                for: NSManagedObjectContext.didSaveObjectsNotification,
                object: coreDataContainer.viewContext
            )
        )
        .throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
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

    /// Saves all changes in Core Data
    private func save() {
        do {
            try coreDataContainer.viewContext.save()
            fetchWords()
        } catch {
            wordsErrorPublisher.send(.coreDataError(.saveError))
        }
    }
}
