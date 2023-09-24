import CoreData

final class PersistenceController {
    let container: NSPersistentCloudKitContainer
    static let shared = PersistenceController()

    private init() {
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
