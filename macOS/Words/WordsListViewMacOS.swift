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
    
    @State private var isShowingAddView = false
    @State private var searchTerm = ""
    
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
                            homeData.selectedWord == nil
                            ? .secondary
                            : .red)
                }
                Spacer()
                Menu {
                    Button {
                        withAnimation {
                            homeData.sortingState = .def
                        }
                    } label: {
                        if homeData.sortingState == .def {
                            Image(systemName: "checkmark")
                        }
                        Text("Default")
                    }
                    Button {
                        withAnimation {
                            homeData.sortingState = .name
                        }
                    } label: {
                        if homeData.sortingState == .name {
                            Image(systemName: "checkmark")
                        }
                        Text("Name")
                    }
                    Button {
                        withAnimation {
                            homeData.sortingState = .partOfSpeech
                        }
                    } label: {
                        if homeData.sortingState == .partOfSpeech {
                            Image(systemName: "checkmark")
                        }
                        Text("Part of speech")
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(homeData.sortingState.rawValue)
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
            
            List(selection: $homeData.selectedWord) {
                //Search, if user type something into search field, show filtered array
                ForEach(searchTerm.isEmpty ? Array(words.sorted(by: {
                    switch homeData.sortingState {
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
                                    .foregroundColor(homeData.selectedWord == word ? .secondary : .accentColor)
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
        if homeData.selectedWord != nil {
            viewContext.delete(homeData.selectedWord!)
        }
        homeData.selectedWord = nil
        save()
    }
    
    private func save() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print(nsError.localizedDescription)
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
