//
//  WordsDetailViewMacOS.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Bonney on 10/7/21.
//

import SwiftUI

struct WordDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var word: Word
    
    @State private var isEditing = false
    
    var body: some View {
        VStack {
            // MARK: Title and toolbar
            HStack {
                Text(word.wordItself ?? "").font(.title).bold()
                Spacer()
                Button(action: {
                    //favorites
                    word.isFavorite.toggle()
                    save()
                }, label: {
                    Image(systemName: "\(word.isFavorite ? "heart.fill" : "heart")")
                        .foregroundColor(.accentColor)
                })
                Button(action: {
                    if !isEditing {
                        isEditing = true
                    } else {
                        save()
                        isEditing = false
                    }
                }, label: {
                    Text(isEditing ? "Save" : "Edit")
                })
            }
            // MARK: Primary Content
            Spacer()
        }
        .padding()
        .navigationTitle(word.wordItself ?? "")
        
    }
    
    // MARK: Private methods
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
