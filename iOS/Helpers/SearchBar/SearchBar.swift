//
//  SearchBar.swift
//  NativeSearchBar
//
//  Created by Haaris Iqubal on 5/26/21.
//

import SwiftUI
import Combine

class SearchBar: NSObject {
    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    override init() {
        super.init()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
    }
}

extension SearchBar: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchBarText = searchController.searchBar.text {
            NotificationCenter.default.post(name: Publishers.searchTerm, object: nil, userInfo: ["SearchTerm": searchBarText])
        }
    }
}

struct SearchBarModifier: ViewModifier {
    let searchBar: SearchBar
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ViewControllerResolver { viewController in
                    viewController.navigationItem.searchController = searchBar.searchController
                }.frame(width:0, height: 0))
    }
}

extension View {
    func add(_ searchBar: SearchBar) -> some View {
        modifier(SearchBarModifier(searchBar: searchBar))
    }
}
