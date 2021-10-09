//
//  Persistence.swift
//  Shared
//
//  Created by Alexander Bonney on 10/6/21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentCloudKitContainer
    
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
    }
}
