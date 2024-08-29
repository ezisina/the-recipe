//
//  DinnerMenuItem.swift
//  TheRecipe
//
//  Created by Elena Zisina on 7/2/23.
//

import CoreData

class DinnerMenuItem: NSManagedObject, Codable, Ordered, ReferenceContainer {
    
    /// A reference to ``Recipe``
    private var recipeReference: Reference?
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
              throw ImportExportError.managedObjectContextRequired
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        recipeReference = try container.decodeIfPresent(Reference.self, forKey: .recipe)
        order = try container.decode(Int16.self, forKey: .order)

    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(order, forKey: .order)
        try container.encodeIfPresent(summary, forKey: .summary)
        try container.encodeIfPresent(recipe?.reference, forKey: .recipe)
        
      
    }
    
    func resolveReferences() {
        guard let context = managedObjectContext else {
            return
        }
        recipe = recipeReference?.resolve(Recipe.self, inContext: context)
    }
}

// MARK: - Coding keys

extension DinnerMenuItem {
    enum CodingKeys: CodingKey {
        case title, summary, dinnerMenu, recipe, order
    }
}
