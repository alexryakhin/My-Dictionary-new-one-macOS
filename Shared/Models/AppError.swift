//
//  AppError.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 2/19/25.
//

import Foundation

enum AppError: Error {
    case coreDataError(CDError)
    case networkError(NetworkError)
}

enum NetworkError {
    case urlError
    case invalidResponse

    var description: String {
        switch self {
        case .urlError:
            return "Error with URL"
        case .invalidResponse:
            return "Invalid response from the server"
        }
    }
}

enum CDError {
    case fetchError
    case saveError

    var description: String {
        switch self {
        case .fetchError:
            return "Error with fetching data from the storage"
        case .saveError:
            return "Error with saving data to the storage"
        }
    }
}
