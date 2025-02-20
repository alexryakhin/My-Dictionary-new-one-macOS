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
    case internalError(InternalError)
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

enum InternalError: Error {
    case removingWordExampleFailed
    case savingWordExampleFailed
    case removingWordFailed
    case savingWordFailed
    case removingIdiomExampleFailed
    case savingIdiomExampleFailed
    case removingIdiomFailed
    case savingIdiomFailed

    var description: String {
        switch self {
        case .removingWordExampleFailed:
            return "Error removing word example"
        case .savingWordExampleFailed:
            return "Error saving word example"
        case .removingWordFailed:
            return "Error removing word"
        case .savingWordFailed:
            return "Error saving word"
        case .removingIdiomExampleFailed:
            return "Error removing idiom example"
        case .savingIdiomExampleFailed:
            return "Error saving idiom example"
        case .removingIdiomFailed:
            return "Error removing idiom"
        case .savingIdiomFailed:
            return "Error saving idiom"
        }
    }
}
