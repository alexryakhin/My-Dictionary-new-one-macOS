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
    @EnvironmentObject var homeData: HomeViewModel
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Word.timestamp, ascending: true)],
        animation: .default)
    private var words: FetchedResults<Word>
    
    @State private var selectedWord: Word?
    @State private var isShowingAddView = false
    
    var body: some View {
        VStack {
            Spacer().frame(height: 27)
            
            HStack{
                Button {
                    removeWord()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(
                            selectedWord == nil
                            ? .secondary
                            : .red)
                }
                Spacer()
                Button {
                    showAddView()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 10)
            
            HStack {
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search", text: $homeData.search)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(Color.primary.opacity(0.15))
            .cornerRadius(8)
            .padding(.horizontal, 10)
            
            List(selection: $selectedWord) {
                ForEach(words) { word in
                    NavigationLink(destination: WordDetailView(word: word)) {
                        Text(word.wordItself ?? "word")
                    }
                    .tag(word)
                }
                .onDelete(perform: deleteItems)
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $isShowingAddView, onDismiss: nil) {
            AddView(isShowingAddView: $isShowingAddView)
        }
        Text("Select an item")
        
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
