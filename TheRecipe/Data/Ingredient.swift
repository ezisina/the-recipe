//
//  Ingredient.swift
//  TheRecipe
//

import CoreData

/// Ingredient entity.
///
/// Represents a reusable ingredient that is referenced from different places, for example ``RecipeIngredient``.
///
/// Ingredient is required to have unique``name`` property.
class Ingredient: NSManagedObject, Codable, Referenceable {
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
              throw ImportExportError.managedObjectContextRequired
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
    
    var reference: Reference {
        .init(key: "name", value: wrappedName)
    }
}

// MARK: - Coding keys

extension Ingredient {
    enum CodingKeys: CodingKey {
        case name
    }
}
