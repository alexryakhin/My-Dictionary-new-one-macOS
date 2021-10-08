//
//  WordsDetailViewMacOS.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Bonney on 10/7/21.
//

import SwiftUI

struct WordDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var word: Word
    
    var body: some View {
        VStack {
            HStack {
                Text(word.wordItself ?? "").font(.title).bold()
                Spacer()
            }
            Spacer()
        }
        .padding()
        .navigationTitle(word.wordItself ?? "")
    }
    
    private func save() {
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct WordsDetailViewMacOS_Previews: PreviewProvider {
    static let viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            
    static var previews: some View {
                
        let word = Word(context: viewContext)
        word.id = UUID()
        word.wordItself = "Fascinating"
        word.definition = "Extremely interesting"
        word.partOfSpeech = "noun"
        word.phonetic = "fascinating"
        word.timestamp = Date()
        word.isFavorite = true
        
        return NavigationView {
            WordDetailView(word: word)
        }
        
    }
}
