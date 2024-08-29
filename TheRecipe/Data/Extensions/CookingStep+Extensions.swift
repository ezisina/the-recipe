//
//  CookingStep+Extensions.swift
//  The Recipe
//

import Foundation

extension CookingStep {
    /// Non-optional ``directions`` with an empty string as a default value.
    var wrappedDirections: String {
        get { directions ?? "" }
        set { directions = newValue }
    }
    
    /// Wrapped ``order`` represented as Int for easier operations.
    var wrappedOrder: Int {
        get { Int(order) }
        set { order = Int16(newValue) }
    }
    
    /// Non-optional ``ingredients`` with an empty string as a default value.
    var wrappedIngredients: Set<RecipeIngredient> {
        get { ingredients as? Set<RecipeIngredient> ?? [] }
        set { ingredients = newValue as NSSet }
    }
    
    var wrappedIngredientsAsString : String {
        let array = wrappedIngredients.compactMap({$0.ingredient?.name ?? ""})
        return ListFormatter.localizedString(byJoining: array)
//        return array.joined(separator: ", ")
    }
    
    var wrappedImages : Set<RecipeImage> {
        get { images as? Set<RecipeImage> ?? [] }
        set { images = newValue as NSSet}
    }
}

