//
//  Recipe+Reordering.swift
//  TheRecipe
//

import Foundation
import CoreData

/// A protocol designating a Core Data object that has an assigned order to it.
/// In collection, such items should follow the order that is permanently saved.
protocol Ordered: NSManagedObject {
    associatedtype OrderingType: BinaryInteger
    /// Item order, used for sorting.
    var order: OrderingType { get set }
}

extension Collection where Element: Ordered {
    /// Ordered array based on the element order.
    var ordered: [Element] {
        sorted { lhs, rhs in
            lhs.order < rhs.order
        }
    }
    
    // FIXME: This is not performance optimized.
    //
    /// Moves a set of items from their previous positions to the given position.
    ///
    /// Order of items will be updated to reflect the change.
    ///
    ///
    /// - Parameters:
    ///   - indexes:  Indexes in the collection where the original items are located.
    ///   - position: Position where the items should be placed at.
    func move(elementsAt indexes: IndexSet, toPosition position: Int) {
        var orderedSelf = ordered
        orderedSelf.move(fromOffsets: indexes, toOffset: position)
        orderedSelf.enumerated().forEach { index, element in
            element.order = Self.Element.OrderingType(index)
        }
    }
    
    /// Removes the given element from the collection.
    ///
    /// Deletes the element from the associated `NSManagedObjectContext` and reorders the other elements
    /// to reflect the deletion.
    ///
    /// - Parameter element: Element to delete.
    mutating func remove(_ element: Element) {
        guard let context = element.managedObjectContext else {
            return
        }
        context.delete(element)
        reorder()
    }
    
    /// Resets each item order in the collection based on their index in the collection.
    ///
    /// Items order is kept monotonic, starting from zero. Any inconsistency in ordering will be fixed after the call.
    private func reorder() {
        self.ordered.filter { !$0.isDeleted }.enumerated().forEach { index, element in
            element.order = Self.Element.OrderingType(index)
        }
    }
}

