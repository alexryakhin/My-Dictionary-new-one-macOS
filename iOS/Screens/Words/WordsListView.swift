//
//  ContentView.swift
//  Shared
//
//  Created by Alexander Bonney on 10/6/21.
//

import SwiftUI
import CoreData

struct WordsListView: View {
    @EnvironmentObject var persistenceController: PersistenceController
    var searchBar = SearchBar()
    @StateObject var vm = DictionaryViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                if persistenceController.words.isEmpty {
                    ZStack {
                        Color("Background").ignoresSafeArea()
                        VStack {
                            Spacer()
                            Text("Begin to add words to your list\nby tapping on plus icon in upper left corner")
                                .padding(20)
                                .multilineTextAlignment(.center)
                                .lineSpacing(10)
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                    }
                } else {
                    List {
                        Section {
                            ForEach(wordsToShow()) { word in
                                NavigationLink(destination: WordDetailView(word: word)) {
                                    HStack {
                                        Text(word.wordItself ?? "word")
                                            .bold()
                                        Spacer()
                                        if word.isFavorite {
                                            Image(systemName: "heart.fill").font(.caption).foregroundColor(.accentColor)
                                        }
                                        Text(word.partOfSpeech ?? "")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .onDelete(perform: { indexSet in
                                persistenceController.deleteWord(offsets: indexSet)
                            })
                        } footer: {
                            if !wordsToShow().isEmpty {
                                Text(wordsCount)
                            }
                        }
                        if persistenceController.filterState == .search && wordsToShow().count < 10 {
                            Button {
                                vm.inputWord = persistenceController.searchText
                                addItem()
                            } label: {
                                Text("Add '\(persistenceController.searchText.trimmingCharacters(in: .whitespacesAndNewlines))'")
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .add(searchBar)
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        filterMenu
                        sortMenu
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet, onDismiss: {
                vm.resultWordDetails = nil
                vm.inputWord = ""
                vm.status = .blank
            }) {
                AddView(vm: vm)
            }
            Text("Select an item")
        }
    }
    
    private func addItem() {
        hideKeyboard()
        showingAddSheet = true
    }
    
    private func wordsToShow() -> [Word] {
        switch persistenceController.filterState {
        case .none:
            return persistenceController.words
        case .favorite:
            return persistenceController.favoriteWords
        case .search:
            return persistenceController.searchResults
        }
    }
    
    private var wordsCount: String {
        if wordsToShow().count == 1 {
            return "1 word"
        } else {
            return "\(wordsToShow().count) words"
        }
    }
    
    private var filterMenu: some View {
        Menu {
            Button {
                withAnimation {
                    persistenceController.filterState = .none
                }
            } label: {
                if persistenceController.filterState == .none {
                    Image(systemName: "checkmark")
                }
                Text("None")
            }
            Button {
                withAnimation {
                    persistenceController.filterState = .favorite
                }
            } label: {
                if persistenceController.filterState == .favorite {
                    Image(systemName: "checkmark")
                }
                Text("Favorites")
            }
        } label: {
            Label {
                Text("Filter By")
            } icon: {
                Image(systemName: "circle.grid.cross.left.filled")
            }
        }
    }
    
    private var sortMenu: some View {
        Menu {
            Button {
                withAnimation {
                    persistenceController.sortingState = .def
                    persistenceController.sortWords()
                }
            } label: {
                if persistenceController.sortingState == .def {
                    Image(systemName: "checkmark")
                }
                Text("Default")
            }
            Button {
                withAnimation {
                    persistenceController.sortingState = .name
                    persistenceController.sortWords()
                }
            } label: {
                if persistenceController.sortingState == .name {
                    Image(systemName: "checkmark")
                }
                Text("Name")
            }
            Button {
                withAnimation {
                    persistenceController.sortingState = .partOfSpeech
                    persistenceController.sortWords()
                }
            } label: {
                if persistenceController.sortingState == .partOfSpeech {
                    Image(systemName: "checkmark")
                }
                Text("Part of speech")
            }
            
        } label: {
            Label {
                Text("Sort By")
            } icon: {
                Image(systemName: "arrow.up.arrow.down")
            }
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
