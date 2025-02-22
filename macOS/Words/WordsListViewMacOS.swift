import SwiftUI
import Swinject
import SwinjectAutoregistration

struct WordsListView: View {
    private let resolver = DIContainer.shared.resolver

    @Binding private var selectedWord: Word?
    @StateObject private var viewModel: WordsViewModel
    @State private var isShowingAddView = false

    init(
        selectedWord: Binding<Word?>,
        viewModel: WordsViewModel
    ) {
        self._selectedWord = selectedWord
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(selection: $selectedWord) {
            Section {
                // Search, if user type something into search field, show filtered array
                ForEach(viewModel.wordsFiltered) { word in
                    NavigationLink(value: word) {
                        WordsListCellView(model: .init(
                            word: word.wordItself ?? "word",
                            isFavorite: word.isFavorite,
                            partOfSpeech: word.partOfSpeech ?? "")
                        )
                    }
                }
                .onDelete(perform: viewModel.deleteWord)

                if viewModel.filterState == .search && viewModel.wordsFiltered.count < 10 {
                    Button("Add '\(viewModel.searchText.trimmed)'") {
                        isShowingAddView = true
                    }
                }
            } header: {
                toolbar
            } footer: {
                if !viewModel.wordsFiltered.isEmpty {
                    Text(viewModel.wordsCount)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                }
            }
        }
        .navigationTitle("Words")
        .sheet(isPresented: $isShowingAddView) {
            resolver.resolve(AddWordView.self, argument: viewModel.searchText)!
        }
        .onDisappear {
            selectedWord = nil
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        VStack(spacing: 16) {
            HStack {
                sortMenu
                Button {
                    isShowingAddView = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.accentColor)
                }
            }
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
        }
        .padding(8)
    }

    // MARK: - Sort Menu

    private var sortMenu: some View {
        Menu {
            Section {
                Button {
                    viewModel.selectSortingState(.def)
                } label: {
                    if viewModel.sortingState == .def {
                        Image(systemName: "checkmark")
                    }
                    Text("Default")
                }
                Button {
                    viewModel.selectSortingState(.name)
                } label: {
                    if viewModel.sortingState == .name {
                        Image(systemName: "checkmark")
                    }
                    Text("Name")
                }
                Button {
                    viewModel.selectSortingState(.partOfSpeech)
                } label: {
                    if viewModel.sortingState == .partOfSpeech {
                        Image(systemName: "checkmark")
                    }
                    Text("Part of speech")
                }
            } header: {
                Text("Sort by")
            }

            Section {
                Button {
                    viewModel.selectFilterState(.none)
                } label: {
                    if viewModel.filterState == .none {
                        Image(systemName: "checkmark")
                    }
                    Text("None")
                }
                Button {
                    viewModel.selectFilterState(.favorite)
                } label: {
                    if viewModel.filterState == .favorite {
                        Image(systemName: "checkmark")
                    }
                    Text("Favorites")
                }
            } header: {
                Text("Filter by")
            }

        } label: {
            Image(systemName: "arrow.up.arrow.down")
            Text(viewModel.sortingState.rawValue)
        }
    }
}
