//
//  HomeViewModel.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Ryakhin on 11/23/21.
//

import SwiftUI

class HomeViewModel: ObservableObject{
    @Published var selectedTab = "Words"
    
    // Message...
    @Published var message = ""
    
    // Expanded View..
    @Published var isExpanded = false
    
    // Piced Expanded Tab...
    @Published var pickedTab = "Words"
    
    // Selected word
    @Published var selectedWord: Word?
}
