//
//  Ingredient+Extensions.swift
//  The Recipe
//

import Foundation
import CoreData

extension Ingredient: EasyFindable {
    /// Non-optional ``name`` with an empty string as a default value.
    var wrappedName: String {
        name ?? ""
    }
}
