import SwiftUI
import Swinject
import SwinjectAutoregistration

struct IdiomsListView: View {
    private let resolver = DIContainer.shared.resolver
    @Binding private var selectedIdiom: Idiom?
    @StateObject private var viewModel: IdiomsViewModel
    @State private var isShowingAddView = false

    init(
        selectedIdiom: Binding<Idiom?>,
        viewModel: IdiomsViewModel
    ) {
        self._selectedIdiom = selectedIdiom
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(selection: $selectedIdiom) {
            Section {
                // Search, if user type something into search field, show filtered array
                ForEach(idiomsToShow()) { idiom in
                    NavigationLink(value: idiom) {
                        IdiomsListCellView(model: .init(
                            idiom: idiom.idiomItself ?? "idiom",
                            isFavorite: idiom.isFavorite)
                        )
                    }
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
                toolbar
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
        .sheet(isPresented: $isShowingAddView) {
            viewModel.searchText = ""
        } content: {
            resolver.resolve(AddIdiomView.self, argument: viewModel.searchText)!
        }
        .onDisappear {
            selectedIdiom = nil
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        VStack(spacing: 16) {
            HStack {
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
            } header: {
                Text("Filter by")
            }

        } label: {
            Image(systemName: "arrow.up.arrow.down")
            Text(viewModel.sortingState.rawValue)
        }
    }
}
