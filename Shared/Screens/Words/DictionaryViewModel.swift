//
//  DictionaryViewModel.swift
//  My Dictionary
//
//  Created by Alexander Bonney on 6/20/21.
//

import SwiftUI

class DictionaryManager: ObservableObject {
        
    @Published var status: FetchingStatus = .blank
    @Published var inputWord: String = ""
    @Published var resultWordDetails: WordElement?
    @Published var definitions: [String] = []
    
    func fetchData() {
        status = .loading
        if inputWord != "" {
            let stringURL = "https://api.dictionaryapi.dev/api/v2/entries/en/\(inputWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))"
            guard let url = URL(string: stringURL) else {
                DispatchQueue.main.async {
                    self.status = .error
                    print("1 URL: \(stringURL)")
                }
                return
            }
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.status = .error
                        print("2 URL: \(stringURL)")
                        print(error?.localizedDescription)
                    }
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(Words.self, from: data)
                    DispatchQueue.main.async {
                        self.resultWordDetails = decodedData.first!
                        self.status = .ready
                    }
                    
                } catch let error {
                    DispatchQueue.main.async {
                        self.resultWordDetails = nil
                        self.status = .error
                        print("3 URL: \(stringURL)")
                    }
                    print(error.localizedDescription)
                }
            }.resume()
        } else {
            return
        }
    }
    
//    func sort(by what: SortingCases) {
//        DispatchQueue.main.async {
//            withAnimation() {
//                switch what {
//                case .def:
//                    self.sortingState = .def
//                    self.words.sort {
//                        $0.date < $1.date
//                    }
//                    self.filteredWords.sort {
//                        $0.date < $1.date
//                    }
//                case .name:
//                    self.sortingState = .name
//                    self.words.sort {
//                        $0.word < $1.word
//                    }
//                    self.filteredWords.sort {
//                        $0.word < $1.word
//                    }
//                case .partOfSpeech:
//                    self.sortingState = .partOfSpeech
//                    self.words.sort {
//                        $0.partOfSpeech < $1.partOfSpeech
//                    }
//                    self.filteredWords.sort {
//                        $0.partOfSpeech < $1.partOfSpeech
//                    }
//                }
//            }
//        }
//    }
    
//    func filter(by filter: FilterCases) {
//        DispatchQueue.main.async {
//            withAnimation() {
//                var startArray = self.words
//
//                switch filter {
//                case .none:
//                    self.filterState = .none
//                    startArray = self.words
//                case .noun:
//                    self.filterState = .noun
//                    startArray = self.words
//                    startArray.removeAll(where: {$0.partOfSpeech != "noun"})
//                case .verb:
//                    self.filterState = .verb
//                    startArray = self.words
//                    startArray.removeAll(where: {$0.partOfSpeech != "verb"})
//                case .adjective:
//                    self.filterState = .adjective
//                    startArray = self.words
//                    startArray.removeAll(where: {$0.partOfSpeech != "adjective"})
//                case .adverb:
//                    self.filterState = .adverb
//                    startArray = self.words
//                    startArray.removeAll(where: {$0.partOfSpeech != "adverb"})
//                case .exclamation:
//                    self.filterState = .exclamation
//                    startArray = self.words
//                    startArray.removeAll(where: {$0.partOfSpeech != "exclamation"})
//                case .conjunction:
//                    self.filterState = .conjunction
//                    startArray = self.words
//                    startArray.removeAll(where: {$0.partOfSpeech != "conjunction"})
//                case .pronoun:
//                    self.filterState = .pronoun
//                    startArray = self.words
//                    startArray.removeAll(where: {$0.partOfSpeech != "pronoun"})
//                case .favorite:
//                    self.filterState = .favorite
//                    startArray = self.words
//                    startArray.removeAll(where: {$0.isFavorite != true })
//                }
//
//                self.filteredWords = startArray
//            }
//        }
//    }
    
//    func getWords() {
//        let fileName = getDocumentsDirectory().appendingPathComponent("words")
//        let query = CKQuery(recordType: "DictionaryWords", predicate: NSPredicate(value: true))
//
//        do {
//            let words = try Data(contentsOf: fileName)
//            self.words = try JSONDecoder().decode([WordModel].self, from: words)
//        }
//        catch {
//            // something went wrong and it can't load data from the documents directory
//            print("\(error.localizedDescription)")
//
//            // try to load them from iCloud
//        }
//    }
    
//    func save() {
//        do {
//            let fileName = getDocumentsDirectory().appendingPathComponent("words")
//            let words = try JSONEncoder().encode(self.words)
//            try words.write(to: fileName, options: [.atomicWrite, .completeFileProtection])
//
//            let query = CKQuery(recordType: "DictionaryWords", predicate: NSPredicate(value: true))
//            let record = CKRecord(recordType: "DictionaryWords")
//            record.setValue(words, forKey: "words")
//
//
//            dataBase.perform(query, inZoneWith: nil) { records, error in
//                guard let records = records, error == nil else {
//                    return
//                }
//
//                guard !records.isEmpty else {
//                    //if there are no records in database, save brand new
//                    self.saveRecord(record)
//                    return
//                }
//
//                if records.count != 1 {
//                    //there are some records. Remove all of them
//                    records.forEach { record in
//                        self.dataBase.delete(withRecordID: record.recordID) { recordID, error in
//                            if recordID != nil, error == nil {
//                                print("deleted all records")
//                            }
//                        }
//                    }
//                } else {
//                    // there is one
//                    self.dataBase.delete(withRecordID: records.first!.recordID) { recordID, error in
//                        if recordID != nil, error == nil {
//                            print("deleted one record")
//                        }
//                    }
//                }
//                self.saveRecord(record)
//            }
//        }
//        catch {
//            print("\(error.localizedDescription)")
//        }
//    }
    
//    private func saveRecord(_ record: CKRecord) {
//        dataBase.save(record, completionHandler: { record, error in
//            if record != nil, error == nil {
//                print("saved")
//            } else {
//                guard let error = error else { return }
//                print(error.localizedDescription)
//            }
//        })
//    }
//
//    private func updateDataWithNewOneFromCloud() {
//        //check if data on device
//    }
}

enum FetchingStatus {
    case blank
    case ready
    case loading
    case error
}

//enum SortingCases {
//    case def
//    case name
//    case partOfSpeech
//}
//
//enum FilterCases {
//    case none
//    case noun
//    case verb
//    case adjective
//    case adverb
//    case exclamation
//    case conjunction
//    case pronoun
//    case favorite
//}
