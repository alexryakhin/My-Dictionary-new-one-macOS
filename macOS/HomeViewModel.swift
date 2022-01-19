//
//  HomeViewModel.swift
//  Telegram_MacApp (iOS)
//
//  Created by Balaji on 06/01/21.
//

import SwiftUI


class HomeViewModel: ObservableObject{
    
    @Published var selectedTab = "Words"
            
    // Search...
    @Published var search = ""
    
    // Message...
    @Published var message = ""
    
    // Expanded View..
    @Published var isExpanded = false
    
    // Piced Expanded Tab...
    @Published var pickedTab = "Words"
    
    // Sorting
    @Published var sortingState: SortingCases = .def
    
    // Selected word
    @Published var selectedWord: Word?
}
