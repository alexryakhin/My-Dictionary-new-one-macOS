import SwiftUI
import Swinject
import SwinjectAutoregistration

struct IdiomsListView: View {
    private let resolver = DIContainer.shared.resolver
    @Binding private var selectedIdiom: Idiom?
    @StateObject private var viewModel: IdiomsViewModel
    @State private var isShowingAddView = false
    @State private var contextDidSaveDate = Date.now

    init(
        selectedIdiom: Binding<Idiom?>,
        viewModel: IdiomsViewModel
    ) {
        self._selectedIdiom = selectedIdiom
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            ListWithDivider(idiomsToShow()) { idiom in
                IdiomsListCellView(
                    model: .init(
                        idiom: idiom.idiomItself ?? "idiom",
                        isFavorite: idiom.isFavorite,
                        isSelected: selectedIdiom?.id == idiom.id
                    ) {
                        selectedIdiom = idiom
                    }
                )
            }
            .id(contextDidSaveDate)

            if viewModel.filterState == .search && idiomsToShow().count < 10 {
                Button {
                    showAddView()
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
            if !idiomsToShow().isEmpty {
                Text(idiomCount)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(.regularMaterial)
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
                    showAddView()
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
