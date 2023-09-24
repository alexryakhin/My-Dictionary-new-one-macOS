import SwiftUI
import Combine
import CoreData

final class IdiomsViewModel: ObservableObject {
    let persistenceController = PersistenceController.shared
    var cancellable = Set<AnyCancellable>()
    @Published var idioms: [Idiom] = []
    @Published var sortingState: SortingCase = .def
    @Published var filterState: FilterCase = .none
    @Published var searchText = ""
    @Published var selectedIdiom: Idiom?

    init() {
        setupBindings()
        fetchIdioms()
    }

    private func setupBindings() {
        // every time core data gets updated, call fetchWords()
        NotificationCenter.default
            .publisher(for: NSManagedObjectContext.didMergeChangesObjectIDsNotification,
                          object: persistenceController.container.viewContext)
            .throttle(for: 1.0, scheduler: RunLoop.main, latest: true)
            .sink { [unowned self] _ in
                self.fetchIdioms()
            }
            .store(in: &cancellable)

        // react to search input from user
        $searchText.sink { [unowned self] value in
            if value.isEmpty {
                self.filterState = .none
            } else {
                self.filterState = .search
            }
        }.store(in: &cancellable)
    }

    // MARK: - Core Data Managing support

    /// Fetches latest data from Core Data
    private func fetchIdioms() {
        let request = NSFetchRequest<Idiom>(entityName: "Idiom")
        do {
            idioms = try persistenceController.container.viewContext.fetch(request)
            sortIdioms()
        } catch {
            print("Error fetching cities. \(error.localizedDescription)")
        }
    }

    /// Saves all changes in Core Data
    func save() {
        do {
            try persistenceController.container.viewContext.save()
            fetchIdioms()
        } catch let error {
            print("Error with saving data to CD. \(error.localizedDescription)")
        }
        objectWillChange.send()
    }

    func addNewIdiom(idiom: String, definition: String) {
        let newIdiom = Idiom(context: persistenceController.container.viewContext)
        newIdiom.id = UUID()
        newIdiom.idiomItself = idiom
        newIdiom.definition = definition
        newIdiom.timestamp = Date()
        save()
    }

    // MARK: Removing from CD
    func deleteIdiom(offsets: IndexSet) {
        switch filterState {
        case .none:
            withAnimation {
                offsets.map { idioms[$0] }.forEach(persistenceController.container.viewContext.delete)
            }
        case .favorite:
            withAnimation {
                offsets.map { favoriteIdioms[$0] }.forEach(persistenceController.container.viewContext.delete)
            }
        case .search:
            withAnimation {
                offsets.map { searchResults[$0] }.forEach(persistenceController.container.viewContext.delete)
            }
        }
        save()
    }

    /// Removes given word from Core Data
    func delete(idiom: Idiom) {
        persistenceController.container.viewContext.delete(idiom)
        save()
    }

    // MARK: Sorting
    var favoriteIdioms: [Idiom] {
        return self.idioms.filter { $0.isFavorite }
    }

    var searchResults: [Idiom] {
        return self.idioms.filter { idiom in
            if let idiomItself = idiom.idiomItself, !searchText.isEmpty {
                return idiomItself.localizedStandardContains(searchText)
            } else {
                return true
            }
        }
    }

    func sortIdioms() {
        switch sortingState {
        case .def:
            idioms.sort(by: { idiom1, idiom2 in
                idiom1.timestamp! < idiom2.timestamp!
            })
        case .name:
            idioms.sort(by: { idiom1, idiom2 in
                idiom1.idiomItself! < idiom2.idiomItself!
            })
        case .partOfSpeech:
            break
        }
    }
}
