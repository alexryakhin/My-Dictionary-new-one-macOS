import SwiftUI
import Combine
import CoreData

final class WordsViewModel: ObservableObject {

    private let wordsProvider: WordsProviderInterface
    private var cancellables = Set<AnyCancellable>()

    @Published var words: [Word] = []
    @Published var sortingState: SortingCase = .def
    @Published var filterState: FilterCase = .none
    @Published var searchText = ""
    @Published var selectedWord: Word?

    var wordsFiltered: [Word] {
        switch filterState {
        case .none:
            return words
        case .favorite:
            return favoriteWords
        case .search:
            return searchResults
        }
    }

    var favoriteWords: [Word] {
        words.filter { $0.isFavorite }
    }

    var searchResults: [Word] {
        words.filter { word in
            guard let wordItself = word.wordItself, !searchText.isEmpty else { return true }
            return wordItself.localizedStandardContains(searchText)
        }
    }

    var wordsCount: String {
        if wordsFiltered.count == 1 {
            return "1 word"
        } else {
            return "\(wordsFiltered.count) words"
        }
    }

    init(wordsProvider: WordsProviderInterface) {
        self.wordsProvider = wordsProvider
        setupBindings()
    }

    private func setupBindings() {
        wordsProvider.wordsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] words in
                self?.words = words
                self?.sortWords()
                if let selectedWord = self?.selectedWord,
                    !words.contains(selectedWord) {
                    self?.selectedWord = nil
                }
            }
            .store(in: &cancellables)

        // React to the search input from a user
        $searchText
            .sink { [weak self] value in
                self?.filterState = value.isEmpty ? .none : .search
            }
            .store(in: &cancellables)
    }

    func addNewWord(word: String, definition: String, partOfSpeech: String, phonetic: String?) {
        wordsProvider.addNewWord(
            word: word,
            definition: definition,
            partOfSpeech: partOfSpeech,
            phonetic: phonetic
        )
        wordsProvider.saveContext()
    }

    func deleteWord(offsets: IndexSet) {
        switch filterState {
        case .none:
            withAnimation {
                offsets.map { words[$0] }.forEach { [weak self] word in
                    self?.delete(word: word)
                }
            }
        case .favorite:
            withAnimation {
                offsets.map { favoriteWords[$0] }.forEach { [weak self] word in
                    self?.delete(word: word)
                }
            }
        case .search:
            withAnimation {
                offsets.map { searchResults[$0] }.forEach { [weak self] word in
                    self?.delete(word: word)
                }
            }
        }
    }

    func delete(word: Word) {
        wordsProvider.delete(word: word)
        wordsProvider.saveContext()
    }

    // MARK: - Sorting

    func sortWords() {
        switch sortingState {
        case .def:
            words.sort(by: { word1, word2 in
                word1.timestamp! < word2.timestamp!
            })
        case .name:
            words.sort(by: { word1, word2 in
                word1.wordItself! < word2.wordItself!
            })
        case .partOfSpeech:
            words.sort(by: { word1, word2 in
                word1.partOfSpeech! < word2.partOfSpeech!
            })
        }
    }
}
