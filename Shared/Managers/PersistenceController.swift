//
//  Persistence.swift
//  Shared
//
//  Created by Alexander Bonney on 10/6/21.
//

import CoreData

final class PersistenceController {
    let container: NSPersistentCloudKitContainer
    static let shared = PersistenceController()
    
    private init(inMemory: Bool = false) {
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
    }
}
