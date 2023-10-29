//
//  Quiz.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 10/29/23.
//

import Foundation

public enum Quiz: CaseIterable {
    case spelling
    case chooseDefinitions

    var title: String {
        switch self {
        case .spelling:
            return "Spelling"
        case .chooseDefinitions:
            return "Choose definitions"
        }
    }
}
