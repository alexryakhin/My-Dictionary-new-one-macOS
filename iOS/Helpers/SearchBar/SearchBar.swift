//
//  SearchBar.swift
//  NativeSearchBar
//
//  Created by Haaris Iqubal on 5/26/21.
//

import SwiftUI
import Combine

class SearchBar: NSObject {
    @Binding var searchTerm: String
    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    init(searchTerm: Binding<String>) {
        _searchTerm = searchTerm
        super.init()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
    }
}

extension SearchBar: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchBarText = searchController.searchBar.text {
            searchTerm = searchBarText
        }
    }
}

struct SearchBarModifier: ViewModifier {
    let searchBar: SearchBar
    init(searchTerm: Binding<String>) {
        searchBar = SearchBar(searchTerm: searchTerm)
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ViewControllerResolver { viewController in
                    viewController.navigationItem.searchController = searchBar.searchController
                }.frame(width:0, height: 0))
    }
}

extension View {
    func searchable(searchTerm: Binding<String>) -> some View {
        modifier(SearchBarModifier(searchTerm: searchTerm))
    }
}
