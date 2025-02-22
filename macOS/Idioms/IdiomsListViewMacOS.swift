import SwiftUI
import CoreData

struct IdiomsListView: View {
    @ObservedObject private var viewModel: IdiomsViewModel
    @State private var isShowingAddView = false

    init(viewModel: IdiomsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List(selection: $viewModel.selectedIdiom) {
            Section {
                // Search, if user type something into search field, show filtered array
                ForEach(idiomsToShow()) { idiom in
                    NavigationLink(destination: IdiomDetailViewMacOS(viewModel: viewModel)) {
                            IdiomsListCellView(model: .init(
                                idiom: idiom.idiomItself ?? "idiom",
                                isFavorite: idiom.isFavorite)
                            )
                        }
                        .tag(idiom)
                }
                .onDelete(perform: viewModel.deleteIdiom)
                if viewModel.filterState == .search && idiomsToShow().count < 10 {
                    Button {
                        showAddView()
                    } label: {
                        Text("Add '\(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines))'")
                    }
                }
            } header: {
                // MARK: - Toolbar
                VStack(spacing: 16) {
                    HStack {
                        Button {
                            viewModel.deleteCurrentIdiom()
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(
                                    viewModel.selectedIdiom == nil
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
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search", text: $viewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                }
                .padding(8)
            } footer: {
                if !idiomsToShow().isEmpty {
                    Text(idiomCount)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                }
            }
        }
        .navigationTitle("Idioms")
        .sheet(isPresented: $isShowingAddView, onDismiss: {
            viewModel.searchText = ""
        }, content: {
            AddIdiomViewMacOS(
                isShowingAddView: $isShowingAddView,
                viewModel: viewModel
            )
        })
        .onDisappear {
            viewModel.selectedIdiom = nil
        }
    }

    private var idiomCount: String {
        if idiomsToShow().count == 1 {
            return "1 idiom"
        } else {
            return "\(idiomsToShow().count) idioms"
        }
    }

    private func showAddView() {
        isShowingAddView = true
    }

    private func idiomsToShow() -> [Idiom] {
        switch viewModel.filterState {
        case .none:
            return viewModel.idioms
        case .favorite:
            return viewModel.favoriteIdioms
        case .search:
            return viewModel.searchResults
        }
    }

    private var sortMenu: some View {
        Menu {
            Section {
                Button {
                    withAnimation {
                        viewModel.sortingState = .def
                        viewModel.sortIdioms()
                        viewModel.selectedIdiom = nil
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
                        viewModel.sortIdioms()
                        viewModel.selectedIdiom = nil
                    }
                } label: {
                    if viewModel.sortingState == .name {
                        Image(systemName: "checkmark")
                    }
                    Text("Name")
                }
            } header: {
                Text("Sort by")
            }

            Section {
                Button {
                    withAnimation {
                        viewModel.filterState = .none
                        viewModel.selectedIdiom = nil
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
                        viewModel.selectedIdiom = nil
                    }
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

struct IdiomsListCellView: View {
    var model: Model

    var body: some View {
        HStack {
            Text(model.idiom)
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
        }
        .padding(.vertical, 4)
    }

    struct Model {
        let idiom: String
        let isFavorite: Bool
    }
}
