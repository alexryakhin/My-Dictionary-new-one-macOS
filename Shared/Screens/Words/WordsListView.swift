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
    
    private var searchWords = [Word]()
    
    @StateObject var vm = DictionaryManager()
    @State private var showingAddSheet = false
    @State private var searchTerm = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(searchTerm.isEmpty ? Array(words) : words.filter({
                    guard let wordItself = $0.wordItself else { return false }
                    return wordItself.starts(with: searchTerm)
                })) { word in
                    NavigationLink(destination: WordDetailView(word: word)) {
                        Text(word.wordItself ?? "word")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Words")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddView(vm: vm)
            }
            Text("Select an item")
        }
        .searchable(text: $searchTerm)
    }

    private func addItem() {
        showingAddSheet = true
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
