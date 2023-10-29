import SwiftUI
import CoreData
import StoreKit

struct WordsListView: View {
    @AppStorage(UDKeys.isShowingRating) var isShowingRating: Bool = true
    @ObservedObject private var wordsViewModel: WordsViewModel
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var isShowingAddSheet = false

    init(wordsViewModel: WordsViewModel) {
        self.wordsViewModel = wordsViewModel
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $wordsViewModel.selectedWord) {
                if !wordsToShow().isEmpty {
                    Section {
                        ForEach(wordsToShow()) { word in
                            NavigationLink(value: word) {
                                WordListCellView(model: .init(
                                    word: word.wordItself ?? "word",
                                    isFavorite: word.isFavorite,
                                    partOfSpeech: word.partOfSpeech ?? "")
                                )
                            }
                        }
                        .onDelete(perform: { indexSet in
                            wordsViewModel.deleteWord(offsets: indexSet)
                        })
                    } header: {
                        if let title = wordsViewModel.filterState.title {
                            Text(title)
                        }
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
            .overlay {
                if wordsViewModel.words.isEmpty {
                    EmptyListView(text: "Begin to add words to your list\nby tapping on plus icon in upper left corner")
                }
            }
            .searchable(text: $wordsViewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Words")
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
                AddView(
                    dictionaryViewModel: DictionaryViewModel(),
                    wordsViewModel: wordsViewModel
                )
            }
        } detail: {
            if let word = wordsViewModel.selectedWord {
                WordDetailView(wordsViewModel: wordsViewModel)
            } else {
                Text("Select a word")
            }
        }
        .navigationSplitViewStyle(.balanced)
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

#Preview {
    WordsListView(wordsViewModel: WordsViewModel())
}

struct WordListCellView: View {
    var model: Model

    var body: some View {
        HStack {
            Text(model.word)
                .bold()
            Spacer()
            if model.isFavorite {
                Label {
                    EmptyView()
                } icon: {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                }
            }
            Text(model.partOfSpeech)
                .foregroundColor(.secondary)
        }
    }

    struct Model {
        let word: String
        let isFavorite: Bool
        let partOfSpeech: String
    }
}
