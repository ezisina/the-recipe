//
//  Dinner+Extensions.swift
//  TheRecipe
//
//  Created by Elena Zisina on 7/4/23.
//

import Foundation
extension DinnerMenu: EasyFindable, TagProvider {
    /// Non-optional ``title`` with an empty string as a default value.
    var wrappedName: String {
        get { title ?? "" }
        set { title = newValue }
    }
    /// Non-optional ``descr`` with an empty string as a default value.
    var wrappedDescription: String {
        get { descr ?? "" }
        set { descr = newValue }
    }
    /// Non-optional ``source`` with an empty string as a default value.
    var wrappedSource: String {
        get { source ?? "" }
        set { source = newValue }
    }
    /// Non-optional ``dinnerMenuItems`` cast to the proper type.
    var wrappedDinnerMenuItems: Set<DinnerMenuItem> {
        get { dinnerMenuItems as? Set<DinnerMenuItem> ?? [] }
        set { dinnerMenuItems = newValue as NSSet }
    }
    /// Non-optional ``tags``  cast to the proper type.
    var wrappedTags: Set<Tag> {
        get { tags as? Set<Tag> ?? [] }
        set { tags = newValue as NSSet }
    }
    
    // MARK: - Predicates
    
    /// Builds a conditional predicate based on the given  tag or search query.
    ///
    /// `tagSelection` and `query` are mutually exclusive.
    ///
    /// - If `query` is not empty, it will take precedence over the `tagSelection` and the resulting
    ///     predicate will be built to match various parts of the recipe, including title, summary, and tags.
    ///     The search is performed globally.
    /// - When `query` is empty, the predicate will match all records in case `tagSelection` equals to ``Selection/allrecipes``,
    ///     or `nil`. Otherwise it will match only the recipes tagged with the given tag.
    ///
    /// - Parameter tagSelection: Selected tag.
    /// - Parameter searchQuery:  Search query.
    ///
    /// - Returns: Predicate to fetch the result based on selection.
    static func predicate(forTaggedWith tagSelection: Selection<Tag>?, orMatching searchQuery: String = "") -> NSPredicate {
        guard !searchQuery.isEmpty else {
            if case let .one(tag) = tagSelection {
                return .init(format: "%K contains[cd] %@", #keyPath(DinnerMenu.tags), tag)
            }
            return .init(value: true)
        }
        return .init(format: "%K contains[cd] %@ OR %K contains[cd] %@ OR ANY %K.name contains[cd] %@",
                     #keyPath(DinnerMenu.title), searchQuery,
                     #keyPath(DinnerMenu.descr), searchQuery,
                     #keyPath(DinnerMenu.tags), searchQuery
        )
    }
}
