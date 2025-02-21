import SwiftUI
import CoreData
import StoreKit
import Swinject
import SwinjectAutoregistration

struct WordsListView: View {
    private let resolver = DIContainer.shared.resolver
    @AppStorage(UDKeys.isShowingRating) var isShowingRating: Bool = true
    @StateObject private var viewModel: WordsViewModel
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var isShowingAddSheet = false
    @State private var contextDidSaveDate = Date.now

    init(viewModel: WordsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $viewModel.selectedWord) {
                if !viewModel.wordsFiltered.isEmpty {
                    Section {
                        ForEach(viewModel.wordsFiltered) { word in
                            NavigationLink(value: word) {
                                WordListCellView(model: .init(
                                    word: word.wordItself ?? "word",
                                    isFavorite: word.isFavorite,
                                    partOfSpeech: word.partOfSpeech ?? "")
                                )
                            }
                        }
                        .onDelete(perform: { indexSet in
                            viewModel.deleteWord(offsets: indexSet)
                        })
                    } header: {
                        if let title = viewModel.filterState.title {
                            Text(title)
                        }
                    } footer: {
                        if !viewModel.wordsFiltered.isEmpty {
                            Text(viewModel.wordsCount)
                        }
                    }
                    .id(contextDidSaveDate)
                }
                if viewModel.filterState == .search && viewModel.wordsFiltered.count < 10 {
                    Button {
                        addItem()
                    } label: {
                        Text("Add '\(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines))'")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .overlay {
                if viewModel.words.isEmpty {
                    EmptyListView(text: "Begin to add words to your list\nby tapping on plus icon in upper left corner")
                }
            }
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
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
                resolver.resolve(AddWordView.self, argument: viewModel.searchText)!
            }
        } detail: {
            if let word = viewModel.selectedWord {
                resolver ~> (WordDetailsView.self, word)
            } else {
                Text("Select a word")
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onReceive(NotificationCenter.default.coreDataDidSavePublisher) { _ in
            contextDidSaveDate = .now
        }
    }

    private func addItem() {
        if isShowingRating && viewModel.words.count > 15 {
            SKStoreReviewController.requestReview()
            isShowingRating = false
        }
        isShowingAddSheet = true
    }

    private var filterMenu: some View {
        Menu {
            Button {
                withAnimation {
                    viewModel.filterState = .none
                }
            } label: {
                if viewModel.filterState == .none {
                    Image(systemName: "checkmark")
                }
                Text("None")
            }
            Button {
                withAnimation {
                    viewModel.filterState = .favorite
                }
            } label: {
                if viewModel.filterState == .favorite {
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
                    viewModel.sortingState = .def
                    viewModel.sortWords()
                }
            } label: {
                if viewModel.sortingState == .def {
                    Image(systemName: "checkmark")
                }
                Text("Default")
            }
            Button {
                withAnimation {
                    viewModel.sortingState = .name
                    viewModel.sortWords()
                }
            } label: {
                if viewModel.sortingState == .name {
                    Image(systemName: "checkmark")
                }
                Text("Name")
            }
            Button {
                withAnimation {
                    viewModel.sortingState = .partOfSpeech
                    viewModel.sortWords()
                }
            } label: {
                if viewModel.sortingState == .partOfSpeech {
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
    DIContainer.shared.resolver ~> WordsListView.self
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
