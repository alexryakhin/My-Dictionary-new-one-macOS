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
    @State private var selectedWord: Word?
    @State private var contextDidSaveDate = Date.now

    init(viewModel: WordsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedWord) {
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
                        .onDelete(perform: viewModel.deleteWord)
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
                    EmptyListView(
                        label: "No words yet",
                        description: "Begin to add words to your list by tapping on plus icon in upper left corner"
                    ) {
                        Button("Add your first word!", action: addItem)
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .if(viewModel.words.isNotEmpty, transform: { view in
                view.searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            })
            .navigationTitle("Words")
            .listStyle(.insetGrouped)
            .toolbar {
                if viewModel.words.isNotEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
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
            if let selectedWord {
                resolver ~> (WordDetailsView.self, selectedWord)
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
                    viewModel.selectSortingState(.def)
                }
            } label: {
                if viewModel.sortingState == .def {
                    Image(systemName: "checkmark")
                }
                Text("Default")
            }
            Button {
                withAnimation {
                    viewModel.selectSortingState(.name)
                }
            } label: {
                if viewModel.sortingState == .name {
                    Image(systemName: "checkmark")
                }
                Text("Name")
            }
            Button {
                withAnimation {
                    viewModel.selectSortingState(.partOfSpeech)
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
