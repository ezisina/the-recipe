//
//  PreviewProvider+Extensions.swift
//  The Recipe
//

import SwiftUI
import CoreData
#if DEBUG
extension NSManagedObject {
    /// A helper method for `PreviewProvider` to easily access any first object of the preview context.
    ///
    /// Picks the first instance of the given entity from the **preview** context.
    ///
    /// The order is based on `objectID` and is not guaranteed to match the insertion order.
    ///
    /// Example:
    ///
    /// ```swift
    /// struct MyView_Previews: PreviewProvider {
    ///     static var previews: some View {
    ///         MyView(entity: first(MyEntity.self))
    ///     }
    /// }
    /// ```
    ///
    /// - Returns: First entity of the given type or an empty entity if none found.
    static func firstForPreview(predicate: NSPredicate = .init(value: true), sortedBy sortDescriptor: NSSortDescriptor = .init(key: "objectID", ascending: true)) -> Self {
        let context = PersistenceController.preview.container.viewContext
        let req = fetchRequest()
        req.fetchLimit = 1
        req.sortDescriptors = [ sortDescriptor ]
        req.predicate = predicate
        return (try? context.fetch(req).first as? Self) ?? Self(context: context)
    }
}
#endif
