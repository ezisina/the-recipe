//
//  Tag.swift
//  TheRecipe
//

import CoreData

/// Tag entity.
///
/// Represents a reusable tag that is referenced by ``Recipe`` and used to group recipes into a user-defined collection.
///
/// Tag is required to have unique``name`` property.
class Tag: NSManagedObject, Codable, Referenceable {
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
              throw ImportExportError.managedObjectContextRequired
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(isFavorite, forKey: .isFavorite)
    }
    
    var reference: Reference {
        .init(key: "name", value: wrappedName)
    }
}


// MARK: - Coding keys

extension Tag {
    enum CodingKeys: CodingKey {
        case name, isFavorite
    }
}
