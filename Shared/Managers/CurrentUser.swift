//
//  CurrentUser.swift
//  My Dictionary
//
//  Created by Alexander Ryakhin on 10/7/21.
//

import Foundation

class CurrentUserManager {
    
    static let shared = CurrentUserManager()
    
    private init() {}
    
    var hasSeenOnboarding: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        }
        set {
            return UserDefaults.standard.set(newValue, forKey: "hasSeenOnboarding")
        }
    }
    
//    var age: Int {
//        get {
//            return UserDefaults.standard.integer(forKey: "age")
//        }
//        set {
//            return UserDefaults.standard.set(newValue, forKey: "age")
//        }
//    }

//    var name: String {
//        get {
//            return UserDefaults.standard.string(forKey: "name") ?? ""
//        }
//        set {
//            return UserDefaults.standard.set(newValue, forKey: "name")
//        }
//    }
}
