//
//  DataRoot.swift
//  TheRecipe
//

import CoreData

/// A "root" structure used for import/export operations.
///
/// The struct combines ingredients, tags, and recipes for easier coding.
///
/// The encoding is performed by custom methods in `NSManagedObjectContext` -
/// `export()` and `import(from:)`.
///
/// The struct resolves the references automatically.
struct DataRoot: Codable, ReferenceContainer {
    /// All Ingredients.
    var ingredients: [Ingredient]
    /// All Tags.
    var tags: [Tag]
    /// All Recipes.
    var recipes: [Recipe]
    
    var dinnerMenus: [DinnerMenu]
    /// Initializes the struct by dumping all the data contained in the given context.
    ///
    /// - Parameter context: Managed Object Context to get the data from.
    init(inContext context: NSManagedObjectContext) {
        ingredients = (try? context.fetch(Ingredient.fetchRequest())) ?? []
        tags = (try? context.fetch(Tag.fetchRequest())) ?? []
        recipes = (try? context.fetch(Recipe.fetchRequest())) ?? []
//        dinnerMenus = [] //FIXME: need fetch
        dinnerMenus = (try? context.fetch(DinnerMenu.fetchRequest())) ?? []
    }
    
    func resolveReferences() {
        recipes.forEach { $0.resolveReferences() }
        dinnerMenus.forEach { $0.resolveReferences() }
    }

}
