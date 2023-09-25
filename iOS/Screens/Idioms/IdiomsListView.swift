import SwiftUI

struct IdiomsListView: View {
    @StateObject var idiomsViewModel = IdiomsViewModel()
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var isShowingAddSheet = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $idiomsViewModel.selectedIdiom) {
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
                        .onDelete(perform: { indexSet in
                            idiomsViewModel.deleteIdiom(offsets: indexSet)
                        })
                    } header: {
                        if let title = idiomsViewModel.filterState.title {
                            Text(title)
                        }
                    } footer: {
                        if !idiomsToShow().isEmpty {
                            Text(idiomsCount)
                        }
                    }
                }
                if idiomsViewModel.filterState == .search && idiomsToShow().count < 10 {
                    Button {
                        addItem()
                    } label: {
                        Text("Add '\(idiomsViewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines))'")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .overlay {
                if idiomsViewModel.idioms.isEmpty {
                    EmptyListView(text: "Begin to add idioms to your list\nby tapping on plus icon in upper left corner")
                }
            }
            .searchable(text: $idiomsViewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
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
                idiomsViewModel.searchText = ""
            }, content: {
                AddIdiomView()
                    .environmentObject(idiomsViewModel)
            })
        } detail: {
            if let idiom = idiomsViewModel.selectedIdiom, !idiomsViewModel.idioms.isEmpty  {
                IdiomsDetailView(idiom: idiom)
                    .environmentObject(idiomsViewModel)
            } else {
                Text("Select an idiom")
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    private func addItem() {
        isShowingAddSheet = true
    }

    private func idiomsToShow() -> [Idiom] {
        switch idiomsViewModel.filterState {
        case .none:
            return idiomsViewModel.idioms
        case .favorite:
            return idiomsViewModel.favoriteIdioms
        case .search:
            return idiomsViewModel.searchResults
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
                    idiomsViewModel.filterState = .none
                }
            } label: {
                if idiomsViewModel.filterState == .none {
                    Image(systemName: "checkmark")
                }
                Text("None")
            }
            Button {
                withAnimation {
                    idiomsViewModel.filterState = .favorite
                }
            } label: {
                if idiomsViewModel.filterState == .favorite {
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
                    idiomsViewModel.sortingState = .def
                    idiomsViewModel.sortIdioms()
                }
            } label: {
                if idiomsViewModel.sortingState == .def {
                    Image(systemName: "checkmark")
                }
                Text("Default")
            }
            Button {
                withAnimation {
                    idiomsViewModel.sortingState = .name
                    idiomsViewModel.sortIdioms()
                }
            } label: {
                if idiomsViewModel.sortingState == .name {
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
