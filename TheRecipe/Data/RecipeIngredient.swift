//
//  RecipeIngredient.swift
//  TheRecipe
//

import CoreData

/// The entity that represents a single recipe ingredient.
///
/// It contains necessary information like the amount needed and the measurement unit, as well as the reference to an ``Ingredient``.
///
/// Recipe ingredients conform to ``Ordered`` protocol, which means they contain ``RecipeIngredient/order`` field and
/// can be arranged in a specific order in a collection.
class RecipeIngredient: NSManagedObject, Codable, Ordered, ReferenceContainer {
    
    /// List of references to Ingredient
    private var ingredientReference: Reference?
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
              throw ImportExportError.managedObjectContextRequired
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        amount = try container.decode(Double.self, forKey: .amount)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        order = try container.decode(Int16.self, forKey: .order)
        unit = try container.decodeIfPresent(String.self, forKey: .unit)
        ingredientReference = try container.decodeIfPresent(Reference.self, forKey: .ingredient)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(comment, forKey: .comment)
        try container.encode(order, forKey: .order)
        try container.encode(unit, forKey: .unit)
        if let ingredientRef = ingredient?.reference {
            try container.encode(ingredientRef, forKey: .ingredient)
        }
    }
    
    func resolveReferences() {
        guard let context = managedObjectContext else {
            return
        }
        
        ingredient = ingredientReference?.resolve(Ingredient.self, inContext: context)
    }
}


// MARK: - Coding keys

extension RecipeIngredient {
    enum CodingKeys: CodingKey {
        case amount, comment, order, unit, ingredient
    }
}
