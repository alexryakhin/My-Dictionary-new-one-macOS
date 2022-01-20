//
//  DictionaryViewModel.swift
//  My Dictionary
//
//  Created by Alexander Bonney on 6/20/21.
//

import SwiftUI
import Combine

class DictionaryViewModel: ObservableObject {
    @Published var status: FetchingStatus = .blank
    @Published var inputWord: String = ""
    @Published var resultWordDetails: WordElement?
    
    var cancellables = Set<AnyCancellable>()
    
    func fetchData() throws {
        status = .loading
        let stringURL = "https://api.dictionaryapi.dev/api/v2/entries/en/\(inputWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))"
        guard let url = URL(string: stringURL) else {
            status = .error
            throw URLError(.badURL)
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .retry(2)
            .receive(on: DispatchQueue.main)
            .tryMap { (data, response) -> Data in
                guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
                    self.status = .error
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: Words.self, decoder: JSONDecoder())
            .sink { completion in
                switch completion {
                case .finished:
                    print("COMPLETION: \(completion)")
                case .failure:
                    self.resultWordDetails = nil
                    self.status = .error
                }
            } receiveValue: { [weak self] words in
                self?.resultWordDetails = words.first!
                self?.status = .ready
            }
            .store(in: &cancellables)
    }
}
