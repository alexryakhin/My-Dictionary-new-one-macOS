import CoreData

protocol CoreDataContainerInterface {
    var viewContext: NSManagedObjectContext { get }
}

final class CoreDataContainer: CoreDataContainerInterface {
    private let container: NSPersistentCloudKitContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init() {
        container = NSPersistentCloudKitContainer(name: "My_Dictionary")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                print(error.localizedDescription)
            }
        })

        // Update data automatically
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
}
