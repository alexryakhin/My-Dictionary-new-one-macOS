//
//  IdiomsListView.swift
//  My Dictionary (iOS)
//
//  Created by Alexander Ryakhin on 1/21/22.
//

import SwiftUI

struct IdiomsListView: View {
    @State private var searchBarText = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<20) { index in
                    Text("\(index + 1) Idiom")
                }
            }
            .navigationTitle("Idioms")
            .searchable(searchTerm: $searchBarText)
            .onChange(of: searchBarText) { newValue in
                print(newValue)
            }
        }
    }
}

struct IdiomsListView_Previews: PreviewProvider {
    static var previews: some View {
        IdiomsListView()
    }
}
