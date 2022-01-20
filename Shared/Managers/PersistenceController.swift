//
//  Persistence.swift
//  Shared
//
//  Created by Alexander Bonney on 10/6/21.
//

import CoreData
import SwiftUI
import Combine


final class PersistenceController: ObservableObject {
    private let container: NSPersistentCloudKitContainer
    var cancellable = Set<AnyCancellable>()
    @Published var words: [Word] = []
    @Published var sortingState: SortingCase = .def
    @Published var filterState: FilterCase = .none
    var searchText = ""
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "My_Dictionary")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print(error.localizedDescription)
            }
        })
        
        // Update data automatically
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        NotificationCenter.default
            .publisher(for: NSManagedObjectContext.didMergeChangesObjectIDsNotification, object: container.viewContext)
            .sink { _ in
                self.fetchWords()
            }
            .store(in: &cancellable)
        NotificationCenter.default
            .publisher(for: Publishers.searchTerm)
            .sink { notification in
                let text = notification.userInfo!["SearchTerm"] as! String
                self.searchText = text
                if !text.isEmpty {
                    self.filterState = .search
                } else {
                    self.filterState = .none
                }
            }
            .store(in: &cancellable)
        fetchWords()
    }
    
    // MARK: - Core Data Managing support
    
    /// Fetches latest data from Core Data
    private func fetchWords() {
        let request = NSFetchRequest<Word>(entityName: "Word")
        do {
            words = try container.viewContext.fetch(request)
            sortWords()
        } catch {
            print("Error fetching cities. \(error.localizedDescription)")
        }
    }

    /// Saves all changes in Core Data
    func save() {
        do {
            try container.viewContext.save()
            fetchWords()
        } catch let error {
            print("Error with saving data to CD. \(error.localizedDescription)")
        }
        objectWillChange.send()
    }
    
    func addNewWord(word: String, definition: String, partOfSpeech: String, phonetic: String?) {
        let newWord = Word(context: container.viewContext)
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
                offsets.map { words[$0] }.forEach(container.viewContext.delete)
            }
        case .favorite:
            withAnimation {
                offsets.map { favoriteWords[$0] }.forEach(container.viewContext.delete)
            }
        case .search:
            withAnimation {
                offsets.map { searchResults[$0] }.forEach(container.viewContext.delete)
            }
        }
        save()
    }
    
    /// Removes given word from Core Data
    func delete(word: Word) {
        container.viewContext.delete(word)
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
