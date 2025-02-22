import SwiftUI
import Swinject
import SwinjectAutoregistration

struct WordsListView: View {
    private let resolver = DIContainer.shared.resolver

    @ObservedObject private var viewModel: WordsViewModel
    @State private var isShowingAddView = false

    init(viewModel: WordsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List(selection: $viewModel.selectedWord) {
            Section {
                // Search, if user type something into search field, show filtered array
                ForEach(viewModel.wordsFiltered) { word in
                    NavigationLink(destination: WordDetailView(viewModel: viewModel)) {
                        WordsListCellView(model: .init(
                            word: word.wordItself ?? "word",
                            isFavorite: word.isFavorite,
                            partOfSpeech: word.partOfSpeech ?? "")
                        )
                    }
                    .tag(word)
                }
                .onDelete(perform: viewModel.deleteWord)

                if viewModel.filterState == .search && viewModel.wordsFiltered.count < 10 {
                    Button("Add '\(viewModel.searchText.trimmed)'") {
                        isShowingAddView = true
                    }
                }
            } header: {
                // MARK: - Toolbar
                VStack(spacing: 16) {
                    HStack {
                        if let selectedWord = viewModel.selectedWord {
                            Button {
                                viewModel.delete(word: selectedWord)
                                viewModel.selectedWord = nil
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(
                                        viewModel.selectedWord == nil
                                        ? .secondary
                                        : .red)
                            }
                        }
                        Spacer()
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
        .sheet(isPresented: $isShowingAddView, onDismiss: nil) {
            resolver ~> AddWordView.self
//            AddView(
//                isShowingAddView: $isShowingAddView,
//                dictionaryViewModel: DictionaryViewModel(),
//                viewModel: viewModel
//            )
        }
    }

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

