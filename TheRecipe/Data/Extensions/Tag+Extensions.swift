//
//  Tag+Extensions.swift
//  The Recipe
//

import Foundation

extension Tag: EasyFindable {
    /// Non-optional ``name`` with an empty string as a default value.
    var wrappedName: String {
        name ?? ""
    }
    /// Non-optional ``recipes`` cast to the proper type.
    var wrappedRecipes: Set<Recipe> {
        recipes as? Set<Recipe> ?? []
    }
    var wrappedDinnerMenus: Set<DinnerMenu> {
        dinnerMenus as? Set<DinnerMenu> ?? []
    }
    
    static func predicate(forTaggedWith tagSelection: Selection<Tag>?) -> NSPredicate {
        
        if tagSelection == .allrecipes {
            return .init(format: "%K > 0", #keyPath(Tag.recipesCount) )
        } else if tagSelection == .alldinnermenus {
            return .init(format: "%K > 0", #keyPath(Tag.dinnerMenusCount) )
        } else if case let .one(tag) = tagSelection {
            return .init(format: "%K contains[cd] %@", #keyPath(Tag.name), tag.wrappedName)
        }
        
        return .init(value: true)
    }
}
