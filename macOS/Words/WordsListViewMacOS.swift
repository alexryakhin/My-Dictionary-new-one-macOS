//
//  WordsListView.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Bonney on 10/6/21.
//

import SwiftUI
import CoreData
import AVFoundation

struct WordsListView: View {
    @EnvironmentObject var wordsViewModel: WordsViewModel
    @State private var isShowingAddView = false
    @State private var selectedWord: Word?

    var body: some View {
        VStack {
            Spacer().frame(height: 27)
            // MARK: Toolbar
            HStack {
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
                sortMenu
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
                TextField("Search", text: $wordsViewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(Color.primary.opacity(0.15))
            .cornerRadius(8)
            .padding(.horizontal, 10)

            Section {
                List(selection: $selectedWord) {
                    // Search, if user type something into search field, show filtered array
                    ForEach(wordsToShow()) { word in
                        NavigationLink(destination: WordDetailView(word: word).environmentObject(wordsViewModel)) {
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
                    .onDelete(perform: { indexSet in
                        wordsViewModel.deleteWord(offsets: indexSet)
                    })
                    if wordsViewModel.filterState == .search && wordsToShow().count < 10 {
                        Button {
                            showAddView()
                        } label: {
                            Text("Add '\(wordsViewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines))'")
                        }
                    }
                }
            } footer: {
                if !wordsToShow().isEmpty {
                    Text(wordsCount)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                }
            }
        }
        .navigationTitle("My Dictionary")
        .ignoresSafeArea()
        .sheet(isPresented: $isShowingAddView, onDismiss: nil) {
            AddView(isShowingAddView: $isShowingAddView)
        }
    }

    private var wordsCount: String {
        if wordsToShow().count == 1 {
            return "1 word"
        } else {
            return "\(wordsToShow().count) words"
        }
    }

    private func showAddView() {
        isShowingAddView = true
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

    private func removeWord() {
        if selectedWord != nil {
            wordsViewModel.delete(word: selectedWord!)
        }
        selectedWord = nil
    }

    private var sortMenu: some View {
        Menu {
            Section {
                Button {
                    withAnimation {
                        wordsViewModel.sortingState = .def
                        wordsViewModel.sortWords()
                        selectedWord = nil
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
                        selectedWord = nil
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
                        selectedWord = nil
                    }
                } label: {
                    if wordsViewModel.sortingState == .partOfSpeech {
                        Image(systemName: "checkmark")
                    }
                    Text("Part of speech")
                }
            } header: {
                Text("Sort by")
            }

            Section {
                Button {
                    withAnimation {
                        wordsViewModel.filterState = .none
                        selectedWord = nil
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
                        selectedWord = nil
                    }
                } label: {
                    if wordsViewModel.filterState == .favorite {
                        Image(systemName: "checkmark")
                    }
                    Text("Favorites")
                }
            } header: {
                Text("Filter by")
            }

        } label: {
            Image(systemName: "arrow.up.arrow.down")
            Text(wordsViewModel.sortingState.rawValue)
        }
    }
}
