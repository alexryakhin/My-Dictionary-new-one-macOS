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
    let container: NSPersistentCloudKitContainer
    var bag = Set<AnyCancellable>()
    @Published var words: [Word] = []
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "My_Dictionary")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
//        RESET CORE DATA IF THERE ARE ERRORS WITH different versions of entities
//        try? NSPersistentStoreCoordinator().destroyPersistentStore(at: container.persistentStoreDescriptions.first!.url!, ofType: "My_Dictionary", options: nil)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print(error.localizedDescription)
            }
        })
        
        // update data automatically
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        NotificationCenter.default
            .publisher(for: NSManagedObjectContext.didMergeChangesObjectIDsNotification, object: container.viewContext)
            .sink { _ in
                self.fetchWords()
            }
            .store(in: &bag)
        fetchWords()
    }
    
    // MARK: - Core Data Saving support
    
    private func fetchWords() {
        let request = NSFetchRequest<Word>(entityName: "Word")
        do {
            words = try container.viewContext.fetch(request)
            words.sort(by: { word1, word2 in
                word1.timestamp! < word2.timestamp!
            })
        } catch {
            print("Error fetching cities. \(error.localizedDescription)")
        }
    }

    func save() {
        do {
            try container.viewContext.save()
            fetchWords()
        } catch let error {
            print("Error with saving data to CD. \(error.localizedDescription)")
        }
        objectWillChange.send()
    }

}
