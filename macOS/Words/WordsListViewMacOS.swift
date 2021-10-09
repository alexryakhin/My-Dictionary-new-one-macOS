//
//  ContentView.swift
//  Shared
//
//  Created by Alexander Bonney on 10/6/21.
//

import SwiftUI
import CoreData
import AVFoundation

struct WordsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var homeData: HomeViewModel
        
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Word.timestamp, ascending: true)],
        animation: .default)
    private var words: FetchedResults<Word>
    
    @State private var selectedWord: Word?
    @State private var isShowingAddView = false
    @State private var searchTerm = ""
    @State private var sortingState: SortingCases = .def
    
    var body: some View {
        VStack {
            Spacer().frame(height: 27)
            // MARK: Toolbar
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
                Menu {
                    Button {
                        withAnimation {
                            sortingState = .def
                        }
                    } label: {
                        if sortingState == .def {
                            Image(systemName: "checkmark")
                        }
                        Text("Default")
                    }
                    Button {
                        withAnimation {
                            sortingState = .name
                        }
                    } label: {
                        if sortingState == .name {
                            Image(systemName: "checkmark")
                        }
                        Text("Name")
                    }
                    Button {
                        withAnimation {
                            sortingState = .partOfSpeech
                        }
                    } label: {
                        if sortingState == .partOfSpeech {
                            Image(systemName: "checkmark")
                        }
                        Text("Part of speech")
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(sortingState.rawValue)
                }

                Button {
                    showAddView()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 10)
            // MARK: Search text field
            HStack {
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search", text: $searchTerm)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(Color.primary.opacity(0.15))
            .cornerRadius(8)
            .padding(.horizontal, 10)
            
            List(selection: $selectedWord) {
                //Search, if user type something into search field, show filtered array
                ForEach(searchTerm.isEmpty ? Array(words.sorted(by: {
                    switch sortingState {
                    case .def:
                        return $0.timestamp! < $1.timestamp!
                    case .name:
                        return $0.wordItself! < $1.wordItself!
                    case .partOfSpeech:
                        return $0.partOfSpeech! < $1.partOfSpeech!
                    }
                })) : words.filter({
                    guard let wordItself = $0.wordItself else { return false }
                    return wordItself.lowercased().starts(with: searchTerm.lowercased())})
                ) { word in
                    NavigationLink(destination: WordDetailView(word: word)) {
                        HStack {
                            Text(word.wordItself ?? "word")
                                .bold()
                            Spacer()
                            if word.isFavorite {
                                Image(systemName: "heart.fill")
                                    .font(.caption)
                                    .foregroundColor(selectedWord == word ? .secondary : .accentColor)
                            }
                            Text(word.partOfSpeech ?? "")
                                .foregroundColor(.secondary)
                        }
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
            if searchTerm.isEmpty {
                offsets.map { words[$0] }.forEach(viewContext.delete)
            } else {
                offsets.map { words.filter({
                    guard let wordItself = $0.wordItself else { return false }
                    return wordItself.lowercased().starts(with: searchTerm.lowercased())})[$0] }.forEach(viewContext.delete)
            }
            
            save()
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
        WordsListView()
    }
}
