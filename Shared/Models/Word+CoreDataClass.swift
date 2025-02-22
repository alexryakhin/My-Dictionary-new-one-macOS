//
//  Word+CoreDataClass.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 2/19/25.
//
//

import Foundation
import CoreData

@objc(Word)
public class Word: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word")
    }

    @NSManaged public var definition: String?
    @NSManaged public var examples: Data?
    @NSManaged public var id: UUID?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var partOfSpeech: String?
    @NSManaged public var phonetic: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var wordItself: String?

    public var examplesDecoded: [String] {
        guard let examples,
              let decodedData = try? JSONDecoder().decode([String].self, from: examples)
        else { return [] }
        return decodedData
    }

    public func removeExample(_ example: String) throws {
        var examples = examplesDecoded
        guard let index = examples.firstIndex(of: example) else {
            throw AppError.internalError(.removingWordExampleFailed)
        }
        examples.remove(at: index)
        let newExamplesData = try JSONEncoder().encode(examples)
        self.examples = newExamplesData
    }

    public func removeExample(atOffsets offsets: IndexSet) throws {
        var examples = examplesDecoded
        examples.remove(atOffsets: offsets)

        let newExamplesData = try JSONEncoder().encode(examples)
        self.examples = newExamplesData
    }

    public func addExample(_ example: String) throws {
        guard !example.isEmpty else {
            throw AppError.internalError(.savingWordExampleFailed)
        }
        let newExamples = examplesDecoded + [example]
        let newExamplesData = try JSONEncoder().encode(newExamples)
        self.examples = newExamplesData
    }
}
