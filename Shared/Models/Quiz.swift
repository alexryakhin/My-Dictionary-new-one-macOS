//
//  Quiz.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 10/29/23.
//

import Foundation

enum Quiz: String, CaseIterable, Identifiable {
    case spelling
    case chooseDefinitions

    var id: String { rawValue }

    var title: String {
        switch self {
        case .spelling:
            return "Spelling"
        case .chooseDefinitions:
            return "Choose definitions"
        }
    }
}
