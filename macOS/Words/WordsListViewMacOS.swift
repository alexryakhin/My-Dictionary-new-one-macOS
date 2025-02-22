import SwiftUI
import Swinject
import SwinjectAutoregistration

struct WordsListView: View {
    private let resolver = DIContainer.shared.resolver

    @Binding private var selectedWord: Word?
    @StateObject private var viewModel: WordsViewModel
    @State private var isShowingAddView = false
    @State private var contextDidSaveDate = Date.now

    init(
        selectedWord: Binding<Word?>,
        viewModel: WordsViewModel
    ) {
        self._selectedWord = selectedWord
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            ListWithDivider(viewModel.wordsFiltered) { word in
                WordsListCellView(
                    model: .init(
                        word: word.wordItself ?? "word",
                        partOfSpeech: word.partOfSpeech ?? "",
                        isFavorite: word.isFavorite,
                        isSelected: selectedWord?.id == word.id
                    ) {
                        selectedWord = word
                    }
                )
            }
            .id(contextDidSaveDate)

            if viewModel.filterState == .search && viewModel.wordsFiltered.count < 10 {
                Button {
                    isShowingAddView = true
                } label: {
                    Text("Add '\(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines))'")
                }
            }
        }
        .safeAreaInset(edge: .top) {
            toolbar
                .background(.regularMaterial)
        }
        .safeAreaInset(edge: .bottom) {
            if !viewModel.wordsFiltered.isEmpty {
                Text(viewModel.wordsCount)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(.regularMaterial)
            }
        }
        .navigationTitle("Words")
        .sheet(isPresented: $isShowingAddView) {
            resolver.resolve(AddWordView.self, argument: viewModel.searchText)!
        }
        .onDisappear {
            selectedWord = nil
        }
        .onReceive(NotificationCenter.default.coreDataDidSavePublisher) { _ in
            contextDidSaveDate = .now
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                sortMenu
                Button {
                    isShowingAddView = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.accentColor)
                }
            }
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(.separator)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
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
