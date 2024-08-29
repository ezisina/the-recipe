//
//  Selection.swift
//  The Recipe
//

import CoreData
import SwiftUI

/// A wrapper around allowing to represent either a single element of the given type,
/// or a special case `all` to represent selection of all the times at once.
enum Selection<Subject>: Hashable where Subject: NSManagedObject {
    /// Represents selection of all items at once.
    case all
    case allrecipes
    case alldinnermenus
    /// Represents selection of the particular item.
    case one(Subject)
    /// No selection at all
    case none
}


// MARK: - Convenience Properties

extension Selection where Subject == Tag {
    /// Human readable title.
    var title: String {
        switch self {
        case .allrecipes:
            return NSLocalizedString("All Recipes", comment: "Name of the item in the tags sidebar for All Recipes")
        case .one(let subject):
            return "#\(subject.wrappedName)"
        case .none:
            return "" // Unused with tags
        case .all:
            return "NA" // Let's avoid all because of uncertanly with tags
//            return NSLocalizedString("All Recipes and Dinner Menu", comment: "Name of the item in the tags sidebar for All Recipes")
        case .alldinnermenus:
            return NSLocalizedString("All Menus", comment: "Name of the item in the tags sidebar for All Dinner Menus")
        }
    }
}


//MARK: - Enviroment
//struct DinnerSelectionKey : EnvironmentKey  {
//    static var defaultValue: Selection<DinnerMenu> = .all
//}
//struct TagSelectionKey : EnvironmentKey  {
//    static var defaultValue: Selection<Tag> = .all
//}
//
//extension EnvironmentValues {
//    var selectedTag : Selection<Tag> {
//        get {self[TagSelectionKey.self]}
//        set {self[TagSelectionKey.self] = newValue}
//    }
//    var selectedDinnerMenu : Selection<DinnerMenu> {
//        get {self[DinnerSelectionKey.self]}
//        set {self[DinnerSelectionKey.self] = newValue}
//    }
//}
