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
}
