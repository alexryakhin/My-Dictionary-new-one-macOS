//
//  DictionaryApiService.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 2/19/25.
//

import Foundation

protocol DictionaryApiServiceInterface {
    func getWords(for textInput: String) async throws -> [WordElement]
}

final class DictionaryApiService: DictionaryApiServiceInterface {
    private let baseURLString = "https://api.dictionaryapi.dev/api/v2/entries/en/"

    func getWords(for textInput: String) async throws -> [WordElement] {
        let urlString = "\(baseURLString)\(textInput.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))"

        guard let url = URL(string: urlString) else {
            throw AppError.networkError(.urlError)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)

        return try JSONDecoder().decode([WordElement].self, from: data)
    }
}
