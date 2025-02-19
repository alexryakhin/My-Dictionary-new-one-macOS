import SwiftUI
import Combine
import CoreData
import Swinject
import SwinjectAutoregistration

protocol IdiomsProviderInterface {
    var idiomsPublisher: CurrentValueSubject<[Idiom], Never> { get }
    var idiomsErrorPublisher: PassthroughSubject<AppError, Never> { get }

    func addNewIdiom(_ idiom: String, definition: String)
    func deleteIdiom(_ idiom: Idiom)
}

final class IdiomsProvider: IdiomsProviderInterface {
    private let coreDataContainer: CoreDataContainerInterface

    var idiomsPublisher = CurrentValueSubject<[Idiom], Never>([])
    var idiomsErrorPublisher = PassthroughSubject<AppError, Never>()

    private var cancellable = Set<AnyCancellable>()

    init(coreDataContainer: CoreDataContainerInterface) {
        self.coreDataContainer = coreDataContainer

        setupBindings()
        fetchIdioms()
    }

    // MARK: - Public methods

    func addNewIdiom(_ text: String, definition: String) {
        let newIdiom = Idiom(context: coreDataContainer.viewContext)
        newIdiom.id = UUID()
        newIdiom.idiomItself = text
        newIdiom.definition = definition
        newIdiom.timestamp = Date()
        save()
    }

    /// Removes given idiom from the Core Data
    func deleteIdiom(_ idiom: Idiom) {
        coreDataContainer.viewContext.delete(idiom)
        save()
    }

    // MARK: - Private methods

    private func setupBindings() {
        // every time core data gets updated, call fetchIdioms()
        NotificationCenter.default.managedObjectContextDidMergeChangesObjectIDsPublisher
            .combineLatest(NotificationCenter.default.managedObjectContextDidSavePublisher)
            .throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
            .sink { [weak self] _ in
                self?.fetchIdioms()
            }
            .store(in: &cancellable)
    }

    /// Fetches latest data from Core Data
    private func fetchIdioms() {
        let request = NSFetchRequest<Idiom>(entityName: "Idiom")
        do {
            let idioms = try coreDataContainer.viewContext.fetch(request)
            idiomsPublisher.send(idioms)
        } catch {
            idiomsErrorPublisher.send(.coreDataError(.fetchError))
        }
    }

    /// Saves all changes in Core Data
    private func save() {
        do {
            try coreDataContainer.viewContext.save()
            fetchIdioms()
        } catch {
            idiomsErrorPublisher.send(.coreDataError(.saveError))
        }
    }
}
