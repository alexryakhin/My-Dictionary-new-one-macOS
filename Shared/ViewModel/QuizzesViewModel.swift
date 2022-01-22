//
//  QuizzesViewModel.swift
//  My Dictionary (Shared)
//
//  Created by Alexander Ryakhin on 1/22/22.
//

import SwiftUI
import CoreData

final class QuizzesViewModel: ObservableObject {
    let persistenceController = PersistenceController.shared

    @Published var words: [Word] = []
    
    init() {
        fetchWords()
    }
    
    /// Fetches latest data from Core Data
    private func fetchWords() {
        let request = NSFetchRequest<Word>(entityName: "Word")
        do {
            words = try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Error fetching cities. \(error.localizedDescription)")
        }
    }
}
