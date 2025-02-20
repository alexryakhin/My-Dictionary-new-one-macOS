//
//  Idiom+CoreDataClass.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 2/19/25.
//
//

import Foundation
import CoreData

@objc(Idiom)
public class Idiom: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Idiom> {
        return NSFetchRequest<Idiom>(entityName: "Idiom")
    }

    @NSManaged public var definition: String?
    @NSManaged public var examples: Data?
    @NSManaged public var id: UUID?
    @NSManaged public var idiomItself: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var timestamp: Date?

    public var examplesDecoded: [String] {
        guard let examples, let decodedData = try? JSONDecoder().decode([String].self, from: examples) else { return [] }
        return decodedData
    }

    public func removeExample(_ example: String) throws {
        var examples = examplesDecoded
        guard let index = examples.firstIndex(of: example) else {
            throw AppError.internalError(.removingIdiomExampleFailed)
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
            throw AppError.internalError(.savingIdiomExampleFailed)
        }
        let newExamples = examplesDecoded + [example]
        let newExamplesData = try JSONEncoder().encode(newExamples)
        self.examples = newExamplesData
    }
}
