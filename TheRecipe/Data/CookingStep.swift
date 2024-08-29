//
//  CookingStep.swift
//  TheRecipe
//

import CoreData

/// A cooking step entity.
///
/// Represents a single step of the cooking process, including directions, timing, and the ingredients involved.
///
/// Steps conform to ``Ordered`` protocol, which means they contain ``CookingStep/order`` field and
/// can be arranged in a specific order in a collection.
class CookingStep: NSManagedObject, Codable, Ordered, ReferenceContainer {
    
    /// List of references to RecipeIngredient
    private var ingredientReferences: [Reference] = []

    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
              throw ImportExportError.managedObjectContextRequired
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        directions = try container.decode(String.self, forKey: .directions)
        order = try container.decode(Int16.self, forKey: .order)
        time = try container.decode(Double.self, forKey: .time)
        ingredientReferences = try container.decodeIfPresent([Reference].self, forKey: .ingredients) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(directions, forKey: .directions)
        try container.encode(order, forKey: .order)
        try container.encode(time, forKey: .time)
        if !wrappedIngredients.isEmpty {
            try container.encode(wrappedIngredients.map { $0.reference }, forKey: .ingredients)
        }
    }
    
    func resolveReferences() {
        guard !ingredientReferences.isEmpty, let recipe = recipe else {
            return
        }
        let recipeIngredients = recipe.wrappedIngredients.ordered
        wrappedIngredients = .init(ingredientReferences.compactMap { ref in
            guard let order = Int(ref.value) else { return nil }
            return recipeIngredients[order]
        })
    }
}

// MARK: - Coding keys

extension CookingStep {
    enum CodingKeys: CodingKey {
        case directions, order, time, ingredients
    }
}

// MARK: - RecipeIngredient reference

// A "hidden" reference to the RecipeIngredient based on ingredient order.
// It's hidden because the order is not a unique identifier and cannot be properly resolved by Reference.
// Hence, we still resolve it based on the Recipe, but there is no need for the external code to know about it.
fileprivate extension RecipeIngredient {
    var reference: Reference {
        .init(key: "order", value: "\(wrappedOrder)")
    }
}
