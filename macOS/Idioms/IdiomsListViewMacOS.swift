import SwiftUI
import CoreData

struct IdiomsListViewMacOS: View {
    @EnvironmentObject var idiomsViewModel: IdiomsViewModel
    @State private var isShowingAddView = false
    @State private var selectedIdiom: Idiom?

    var body: some View {
        List(selection: $selectedIdiom) {
            Section {
                // Search, if user type something into search field, show filtered array
                ForEach(idiomsToShow()) { idiom in
                    NavigationLink(destination: IdiomDetailViewMacOS(idiom: idiom)
                        .environmentObject(idiomsViewModel)) {
                            IdiomsListCellView(model: .init(
                                idiom: idiom.idiomItself ?? "word",
                                isFavorite: idiom.isFavorite)
                            )
                        }
                        .tag(idiom)
                }
                .onDelete(perform: { indexSet in
                    idiomsViewModel.deleteIdiom(offsets: indexSet)
                })
                if idiomsViewModel.filterState == .search && idiomsToShow().count < 10 {
                    Button {
                        showAddView()
                    } label: {
                        Text("Add '\(idiomsViewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines))'")
                    }
                }
            } header: {
                // MARK: - Toolbar
                VStack(spacing: 16) {
                    HStack {
                        Button {
                            removeIdiom()
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(
                                    selectedIdiom == nil
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
                        TextField("Search", text: $idiomsViewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                }
                .padding(8)
                .padding(.top, 40)
            } footer: {
                if !idiomsToShow().isEmpty {
                    Text(idiomCount)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                }
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $isShowingAddView, onDismiss: {
            idiomsViewModel.searchText = ""
        }, content: {
            AddIdiomViewMacOS(isShowingAddView: $isShowingAddView)
        })
        .onDisappear {
            selectedIdiom = nil
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
        switch idiomsViewModel.filterState {
        case .none:
            return idiomsViewModel.idioms
        case .favorite:
            return idiomsViewModel.favoriteIdioms
        case .search:
            return idiomsViewModel.searchResults
        }
    }

    private func removeIdiom() {
        if selectedIdiom != nil {
            idiomsViewModel.delete(idiom: selectedIdiom!)
        }
        selectedIdiom = nil
    }

    private var sortMenu: some View {
        Menu {
            Section {
                Button {
                    withAnimation {
                        idiomsViewModel.sortingState = .def
                        idiomsViewModel.sortIdioms()
                        selectedIdiom = nil
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
                        selectedIdiom = nil
                    }
                } label: {
                    if idiomsViewModel.sortingState == .name {
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
                        idiomsViewModel.filterState = .none
                        selectedIdiom = nil
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
                        selectedIdiom = nil
                    }
                } label: {
                    if idiomsViewModel.filterState == .favorite {
                        Image(systemName: "checkmark")
                    }
                    Text("Favorites")
                }
            } header: {
                Text("Filter by")
            }

        } label: {
            Image(systemName: "arrow.up.arrow.down")
            Text(idiomsViewModel.sortingState.rawValue)
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
