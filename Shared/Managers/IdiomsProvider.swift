import SwiftUI
import Combine
import CoreData
import Swinject
import SwinjectAutoregistration

protocol IdiomsProviderInterface {
    var idiomsPublisher: CurrentValueSubject<[Idiom], Never> { get }
    var idiomsErrorPublisher: PassthroughSubject<AppError, Never> { get }

    /// Creates a new idiom into the Core Data (does not save the data)
    func addNewIdiom(_ idiom: String, definition: String)

    /// Removes a given idiom from the Core Data (does not save the data)
    func deleteIdiom(_ idiom: Idiom)

    /// Saves all changes in the Core Data
    func saveContext()
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
    }

    func deleteIdiom(_ idiom: Idiom) {
        coreDataContainer.viewContext.delete(idiom)
    }

    func saveContext() {
        do {
            try coreDataContainer.viewContext.save()
        } catch {
            idiomsErrorPublisher.send(.coreDataError(.saveError))
        }
    }

    // MARK: - Private methods

    private func setupBindings() {
        // every time core data gets updated, call fetchIdioms()
        NotificationCenter.default.managedObjectContextDidMergeChangesObjectIDsPublisher
            .combineLatest(NotificationCenter.default.managedObjectContextDidSavePublisher)
            .throttle(for: 1, scheduler: RunLoop.main, latest: true)
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
}
