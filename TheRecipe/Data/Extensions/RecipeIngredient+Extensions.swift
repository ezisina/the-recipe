//
//  RecipeIngredient+Extensions.swift
//  The Recipe
//

import CoreData


extension RecipeIngredient {
    /// Wrapped ``order`` represented as Int for easier operations.
    var wrappedOrder: Int {
        get { Int(order) }
        set { order = Int16(newValue) }
    }

    /// Wrapped ``unit`` cast to the Unit type.
    var wrappedUnit: Unit? {
        get {
            guard let unit = unit else {
                return nil
            }
            return Units.list.first { $0.symbol == unit }
        }
        set {
            unit = newValue?.symbol
        }
    }
    
    /// Shortcut to the ``Ingredient/name`` that is non-optional, using empty string as a default value.
    var ingredientName: String {
        ingredient?.name ?? ""
    }
    
    
    /// Checks if the given ``RecipeIngredient`` is used in the particular ``CookingStep``.
    ///
    /// - Parameter step: CookingStep to check the usage for.
    /// 
    /// - Returns: True if the ingredient is used in the given step, false otherwise.
    func isInUse(inCookingStep step: CookingStep) -> Bool {
        if case let .some(usedStep) = cookingStep, usedStep == step {
            return true
        }
        return false
    }
    
    /// Checks if the given ``RecipeIngredient`` can be used in the particular ``CookingStep``.
    ///
    /// - Parameter step: CookingStep to check the usage for.
    ///
    /// - Returns: True if the ingredient can be used in the given step, false otherwise.
    func canBeUsed(inCookingStep step: CookingStep) -> Bool {
        guard nil == cookingStep || cookingStep == step || step.wrappedOrder < cookingStep?.wrappedOrder ?? 0 else {
            return false
        }
        return true
    }
}
