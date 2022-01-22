//
//  IdiomsListViewMacOS.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Ryakhin on 1/22/22.
//

import SwiftUI
import CoreData
import AVFoundation

struct IdiomsListViewMacOS: View {
    @EnvironmentObject var idiomsViewModel: IdiomsViewModel
    @EnvironmentObject var homeData: HomeViewModel
    @State private var isShowingAddView = false
    
    var body: some View {
        VStack {
            Spacer().frame(height: 27)
            // MARK: Toolbar
            HStack{
                Button {
                    removeIdiom()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(
                            homeData.selectedIdiom == nil
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
            .padding(.horizontal, 10)
            // MARK: Search text field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $idiomsViewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(Color.primary.opacity(0.15))
            .cornerRadius(8)
            .padding(.horizontal, 10)
            
            Section {
                List(selection: $homeData.selectedIdiom) {
                    //Search, if user type something into search field, show filtered array
                    ForEach(idiomsToShow()) { idiom in
                        NavigationLink(destination: IdiomDetailViewMacOS(idiom: idiom).environmentObject(idiomsViewModel)) {
                            HStack {
                                Text(idiom.idiomItself ?? "word")
                                    .bold()
                                Spacer()
                                if idiom.isFavorite {
                                    Image(systemName: "heart.fill")
                                        .font(.caption)
                                        .foregroundColor(homeData.selectedIdiom == idiom ? .secondary : .accentColor)
                                }
                            }
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
                }
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
        }) {
            AddIdiomViewMacOS(isShowingAddView: $isShowingAddView)
        }
        Text("Select an item")
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
        if homeData.selectedIdiom != nil {
            idiomsViewModel.delete(idiom: homeData.selectedIdiom!)
        }
        homeData.selectedIdiom = nil
    }
    
    private var sortMenu: some View {
        Menu {
            Section {
                Button {
                    withAnimation {
                        idiomsViewModel.sortingState = .def
                        idiomsViewModel.sortIdioms()
                        homeData.selectedIdiom = nil
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
                        homeData.selectedIdiom = nil
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
                        homeData.selectedIdiom = nil
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
                        homeData.selectedIdiom = nil
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
