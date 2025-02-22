import SwiftUI
import Swinject
import SwinjectAutoregistration

struct IdiomsListView: View {
    private let resolver = DIContainer.shared.resolver
    @StateObject private var viewModel: IdiomsViewModel
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var isShowingAddSheet = false
    @State private var contextDidSaveDate = Date.now

    init(viewModel: IdiomsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $viewModel.selectedIdiom) {
                if !idiomsToShow().isEmpty {
                    Section {
                        ForEach(idiomsToShow()) { idiom in
                            NavigationLink(value: idiom) {
                                IdiomListCellView(model: .init(
                                    idiom: idiom.idiomItself ?? "idiom",
                                    isFavorite: idiom.isFavorite)
                                )
                            }
                        }
                        .onDelete(perform: viewModel.deleteIdiom)
                    } header: {
                        if let title = viewModel.filterState.title {
                            Text(title)
                        }
                    } footer: {
                        if !idiomsToShow().isEmpty {
                            Text(idiomsCount)
                        }
                    }
                    .id(contextDidSaveDate)
                }
                if viewModel.filterState == .search && idiomsToShow().count < 10 {
                    Button {
                        addItem()
                    } label: {
                        Text("Add '\(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines))'")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .overlay {
                if viewModel.idioms.isEmpty {
                    EmptyListView(text: "Begin to add idioms to your list\nby tapping on plus icon in upper left corner")
                }
            }
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Idioms")
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
            .sheet(isPresented: $isShowingAddSheet, onDismiss: {
                viewModel.searchText = ""
            }, content: {
                resolver.resolve(AddIdiomView.self, argument: viewModel.searchText)!
            })
        } detail: {
            if let idiom = viewModel.selectedIdiom {
                resolver ~> (IdiomDetailsView.self, idiom)
            } else {
                Text("Select an idiom")
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onReceive(NotificationCenter.default.coreDataDidSavePublisher) { _ in
            contextDidSaveDate = .now
        }
    }

    private func addItem() {
        isShowingAddSheet = true
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

    private var idiomsCount: String {
        if idiomsToShow().count == 1 {
            return "1 idiom"
        } else {
            return "\(idiomsToShow().count) idioms"
        }
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
        } label: {
            Label {
                Text("Sort By")
            } icon: {
                Image(systemName: "arrow.up.arrow.down")
            }
        }
    }
}

struct IdiomListCellView: View {
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
    }

    struct Model {
        var idiom: String
        var isFavorite: Bool
    }
}
