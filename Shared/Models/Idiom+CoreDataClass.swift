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
}
