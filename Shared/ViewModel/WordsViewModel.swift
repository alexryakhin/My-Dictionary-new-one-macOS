//
//  WordsViewModel.swift
//  My Dictionary (Shared)
//
//  Created by Alexander Ryakhin on 1/21/22.
//

import SwiftUI
import Combine
import CoreData

final class WordsViewModel: ObservableObject {
    let persistenceController = PersistenceController.shared
    var cancellable = Set<AnyCancellable>()
    @Published var words: [Word] = []
    @Published var sortingState: SortingCase = .def
    @Published var filterState: FilterCase = .none
    @Published var searchText = ""
        
    init() {
        setupBindings()
        fetchWords()
    }
    
    private func setupBindings() {
        // every time core data gets updated, call fetchWords()
        NotificationCenter.default
            .publisher(for: NSManagedObjectContext.didMergeChangesObjectIDsNotification, object: persistenceController.container.viewContext)
            .throttle(for: 1.0, scheduler: RunLoop.main, latest: true)
            .sink { [unowned self] _ in
                self.fetchWords()
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
    private func fetchWords() {
        let request = NSFetchRequest<Word>(entityName: "Word")
        do {
            words = try persistenceController.container.viewContext.fetch(request)
            sortWords()
        } catch {
            print("Error fetching cities. \(error.localizedDescription)")
        }
    }

    /// Saves all changes in Core Data
    func save() {
        do {
            try persistenceController.container.viewContext.save()
            fetchWords()
        } catch let error {
            print("Error with saving data to CD. \(error.localizedDescription)")
        }
        objectWillChange.send()
    }
    
    func addNewWord(word: String, definition: String, partOfSpeech: String, phonetic: String?) {
        let newWord = Word(context: persistenceController.container.viewContext)
        newWord.id = UUID()
        newWord.wordItself = word
        newWord.definition = definition
        newWord.partOfSpeech = partOfSpeech
        newWord.phonetic = phonetic
        newWord.timestamp = Date()
        save()
    }
    
    // MARK: Removing from CD
    func deleteWord(offsets: IndexSet) {
        switch filterState {
        case .none:
            withAnimation {
                offsets.map { words[$0] }.forEach(persistenceController.container.viewContext.delete)
            }
        case .favorite:
            withAnimation {
                offsets.map { favoriteWords[$0] }.forEach(persistenceController.container.viewContext.delete)
            }
        case .search:
            withAnimation {
                offsets.map { searchResults[$0] }.forEach(persistenceController.container.viewContext.delete)
            }
        }
        save()
    }
    
    /// Removes given word from Core Data
    func delete(word: Word) {
        persistenceController.container.viewContext.delete(word)
        save()
    }
    
    // MARK: Sorting
    var favoriteWords: [Word] {
        return self.words.filter { $0.isFavorite }
    }
    
    var searchResults: [Word] {
        return self.words.filter { word in
            if let wordItself = word.wordItself, !searchText.isEmpty {
                return wordItself.localizedStandardContains(searchText)
            } else {
                return true
            }
        }
    }
    
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
