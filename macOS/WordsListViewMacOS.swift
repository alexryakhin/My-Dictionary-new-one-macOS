//
//  ContentView.swift
//  Shared
//
//  Created by Alexander Bonney on 10/6/21.
//

import SwiftUI
import CoreData

struct WordsListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Word.timestamp, ascending: true)],
        animation: .default)
    private var words: FetchedResults<Word>
    
    @State private var selectedWord: Word?
    @State private var isShowingAddView = false

    var body: some View {
        NavigationView {
            List(selection: $selectedWord) {
                ForEach(words) { word in
                    NavigationLink(destination: WordDetailView(word: word)) {
                        Text(word.wordItself ?? "word")
                    }
                    .tag(word)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Words")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
//                        addItem()
                        showAddView()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.accentColor)
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button {
                        removeWord()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(
                                selectedWord == nil
                                ? .secondary
                                : .red)
                    }
                }
            }
            .sheet(isPresented: $isShowingAddView, onDismiss: nil) {
                AddView()
            }
            Text("Select an item")
        }
        
    }

    private func addItem() {
        withAnimation {
            let newWord = Word(context: viewContext)
            newWord.id = UUID()
            newWord.wordItself = "New Word"
            newWord.definition = "Word's Definition"
            newWord.partOfSpeech = "noun"
            newWord.phonetic = "phonetic symbols"
            newWord.timestamp = Date()

            save()
        }
    }
    
    private func showAddView() {
        isShowingAddView = true
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { words[$0] }.forEach(viewContext.delete)

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
    
    private func removeWord() {
        if selectedWord != nil {
            viewContext.delete(selectedWord!)
        }
        selectedWord = nil
        save()
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

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WordsListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
