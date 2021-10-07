//
//  HomeViewModel.swift
//  Telegram_MacApp (iOS)
//
//  Created by Balaji on 06/01/21.
//

import SwiftUI


class HomeViewModel: ObservableObject{
    
    @Published var selectedTab = ""
            
    // Search...
    @Published var search = ""
    
    // MEssage...
    @Published var message = ""
    
    // Expanded View..
    @Published var isExpanded = false
    
    // Piced Expanded Tab...
    @Published var pickedTab = "Words"
    
    // Send Message....
    
    func fetchData() {
        
    }
}
