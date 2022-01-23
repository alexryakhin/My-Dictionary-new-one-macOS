//
//  IdiomsListView.swift
//  My Dictionary (iOS)
//
//  Created by Alexander Ryakhin on 1/21/22.
//

import SwiftUI

struct IdiomsListView: View {
    @StateObject var idiomsViewModel = IdiomsViewModel()
    @State private var isShowingAddSheet = false

    var body: some View {
        NavigationView {
            VStack {
                if idiomsViewModel.idioms.isEmpty {
                    ZStack {
                        Color("Background").ignoresSafeArea()
                        VStack {
                            Spacer()
                            Text("Begin to add idioms to your list\nby tapping on plus icon in upper left corner")
                                .padding(20)
                                .multilineTextAlignment(.center)
                                .lineSpacing(10)
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                    }
                } else {
                    List {
                        if !idiomsToShow().isEmpty {
                            Section {
                                ForEach(idiomsToShow()) { idiom in
                                    NavigationLink(destination: IdiomsDetailView(idiom: idiom)
                                                    .environmentObject(idiomsViewModel)) {
                                        HStack {
                                            Text(idiom.idiomItself ?? "word")
                                                .bold()
                                            Spacer()
                                            if idiom.isFavorite {
                                                Image(systemName: "heart.fill")
                                                    .font(.caption)
                                                    .foregroundColor(.accentColor)
                                            }
                                        }
                                    }
                                }
                                .onDelete(perform: { indexSet in
                                    idiomsViewModel.deleteIdiom(offsets: indexSet)
                                })
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
                }
            }
            .searchable(searchTerm: $idiomsViewModel.searchText, hideWhenScrolling: false)
            .navigationTitle("Idioms")
            .navigationBarTitleDisplayMode(.inline)
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
            Text("Select an item")
        }
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
