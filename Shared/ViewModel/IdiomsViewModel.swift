import SwiftUI
import Combine
import CoreData

final class IdiomsViewModel: ObservableObject {

    @Published var idioms: [Idiom] = []
    @Published var sortingState: SortingCase = .def
    @Published var filterState: FilterCase = .none
    @Published var searchText = ""
    @Published var selectedIdiom: Idiom?

    private let idiomsProvider: IdiomsProviderInterface
    private var cancellables = Set<AnyCancellable>()

    init(idiomsProvider: IdiomsProviderInterface) {
        self.idiomsProvider = idiomsProvider

        setupBindings()
    }

    private func setupBindings() {
        idiomsProvider.idiomsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] idioms in
                self?.idioms = idioms
                self?.sortIdioms()
            }
            .store(in: &cancellables)

        // React to the search input from a user
        $searchText
            .sink { [weak self] value in
                self?.filterState = value.isEmpty ? .none : .search
            }
            .store(in: &cancellables)
    }

    func addNewIdiom(text: String, definition: String) {
        idiomsProvider.addNewIdiom(text, definition: definition)
    }

    // MARK: Removing from CD
    func deleteIdiom(offsets: IndexSet) {
        switch filterState {
        case .none:
            withAnimation {
                offsets.map { idioms[$0] }.forEach { [weak self] idiom in
                    self?.idiomsProvider.deleteIdiom(idiom)
                }
            }
        case .favorite:
            withAnimation {
                offsets.map { favoriteIdioms[$0] }.forEach { [weak self] idiom in
                    self?.idiomsProvider.deleteIdiom(idiom)
                }
            }
        case .search:
            withAnimation {
                offsets.map { searchResults[$0] }.forEach { [weak self] idiom in
                    self?.idiomsProvider.deleteIdiom(idiom)
                }
            }
        }
    }

    /// Removes given word from Core Data
    func deleteIdiom(_ idiom: Idiom) {
        idiomsProvider.deleteIdiom(idiom)
    }

    /// Removes selected idiom from Core Data
    func deleteCurrentIdiom() {
        guard let idiom = selectedIdiom else { return }
        idiomsProvider.deleteIdiom(idiom)
        selectedIdiom = nil
    }

    // MARK: Sorting
    var favoriteIdioms: [Idiom] {
        idioms.filter { $0.isFavorite }
    }

    var searchResults: [Idiom] {
        idioms.filter { idiom in
            guard let idiomItself = idiom.idiomItself, !searchText.isEmpty else { return true }
            return idiomItself.localizedStandardContains(searchText)
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
