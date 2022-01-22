//
//  ContentView.swift
//  Shared
//
//  Created by Alexander Bonney on 10/6/21.
//

import SwiftUI
import CoreData
import StoreKit

struct WordsListView: View {
    @AppStorage("isShowingRating") var isShowingRating: Bool = true
    @StateObject var wordsViewModel = WordsViewModel()
    @State private var isShowingAddSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                if wordsViewModel.words.isEmpty {
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
                        if !wordsToShow().isEmpty {
                            Section {
                                ForEach(wordsToShow()) { word in
                                    NavigationLink(destination: WordDetailView(word: word).environmentObject(wordsViewModel)) {
                                        HStack {
                                            Text(word.wordItself ?? "word")
                                                .bold()
                                            Spacer()
                                            if word.isFavorite {
                                                Image(systemName:       "heart.fill").font(.caption).foregroundColor(.accentColor)
                                            }
                                            Text(word.partOfSpeech ?? "")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .onDelete(perform: { indexSet in
                                    wordsViewModel.deleteWord(offsets: indexSet)
                                })
                            } footer: {
                                if !wordsToShow().isEmpty {
                                    Text(wordsCount)
                                }
                            }
                        }
                        if wordsViewModel.filterState == .search && wordsToShow().count < 10 {
                            Button {
                                addItem()
                            } label: {
                                Text("Add '\(wordsViewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines))'")
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .searchable(searchTerm: $wordsViewModel.searchText, hideWhenScrolling: false)
            .navigationTitle("Words")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.insetGrouped)
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
            .sheet(isPresented: $isShowingAddSheet) {
                AddView()
                    .environmentObject(wordsViewModel)
            }
            Text("Select an item")
        }
    }
    
    private func addItem() {
        if isShowingRating && wordsViewModel.words.count > 15 {
            SKStoreReviewController.requestReview()
            isShowingRating = false
        }
        isShowingAddSheet = true
    }
    
    private func wordsToShow() -> [Word] {
        switch wordsViewModel.filterState {
        case .none:
            return wordsViewModel.words
        case .favorite:
            return wordsViewModel.favoriteWords
        case .search:
            return wordsViewModel.searchResults
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
                    wordsViewModel.filterState = .none
                }
            } label: {
                if wordsViewModel.filterState == .none {
                    Image(systemName: "checkmark")
                }
                Text("None")
            }
            Button {
                withAnimation {
                    wordsViewModel.filterState = .favorite
                }
            } label: {
                if wordsViewModel.filterState == .favorite {
                    Image(systemName: "checkmark")
                }
                Text("Favorites")
            }
        } label: {
            Label {
                Text("Filter By")
            } icon: {
                Image(systemName: "paperclip")
            }
        }
    }
    
    private var sortMenu: some View {
        Menu {
            Button {
                withAnimation {
                    wordsViewModel.sortingState = .def
                    wordsViewModel.sortWords()
                }
            } label: {
                if wordsViewModel.sortingState == .def {
                    Image(systemName: "checkmark")
                }
                Text("Default")
            }
            Button {
                withAnimation {
                    wordsViewModel.sortingState = .name
                    wordsViewModel.sortWords()
                }
            } label: {
                if wordsViewModel.sortingState == .name {
                    Image(systemName: "checkmark")
                }
                Text("Name")
            }
            Button {
                withAnimation {
                    wordsViewModel.sortingState = .partOfSpeech
                    wordsViewModel.sortWords()
                }
            } label: {
                if wordsViewModel.sortingState == .partOfSpeech {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WordsListView()
    }
}
