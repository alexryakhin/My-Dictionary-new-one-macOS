import SwiftUI
import CoreData

final class QuizzesViewModel: ObservableObject {
    let persistenceController = PersistenceController.shared

    @Published var words: [Word] = []

    /// Fetches latest data from Core Data
    func fetchWords() {
        let request = NSFetchRequest<Word>(entityName: "Word")
        do {
            words = try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Error fetching cities. \(error.localizedDescription)")
        }
    }
}
