//
//  IdiomDetailViewMacOS.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Ryakhin on 1/22/22.
//

import SwiftUI

struct IdiomDetailViewMacOS: View {
    @EnvironmentObject var idiomsViewModel: IdiomsViewModel
    @ObservedObject var idiom: Idiom
    
    var body: some View {
        Text("Hello, World!")
    }
}
