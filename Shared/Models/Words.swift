// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let words = try? newJSONDecoder().decode(Words.self, from: jsonData)

import Foundation

// MARK: - WordElement
struct WordElement: Codable {
    let word: String
    let phonetic: String?
    let phonetics: [Phonetic]
    let origin: String?
    let meanings: [Meaning]
}

// MARK: - Meaning
struct Meaning: Codable, Hashable {
    let partOfSpeech: String
    let definitions: [Definition]
}

// MARK: - Definition
struct Definition: Codable, Hashable {
    let definition: String
    let example: String?
    let synonyms, antonyms: [String]
}

// MARK: - Phonetic
struct Phonetic: Codable {
    let text, audio: String?
}

enum PartOfSpeech: String, CaseIterable {
    case noun
    case verb
    case adjective
    case adverb
    case exclamation
    case conjunction
    case pronoun
    case number
    case unknown
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
