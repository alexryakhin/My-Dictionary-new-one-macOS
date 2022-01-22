//
//  IdiomsListView.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Ryakhin on 1/22/22.
//

import SwiftUI

struct IdiomsListView: View {
    @StateObject var idiomsViewModel = IdiomsViewModel()
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct IdiomsListView_Previews: PreviewProvider {
    static var previews: some View {
        IdiomsListView()
    }
}
