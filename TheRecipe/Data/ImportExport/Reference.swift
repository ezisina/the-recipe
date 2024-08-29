//
//  Reference.swift
//  TheRecipe
//

import CoreData


/// A reference to a Core Data object that is used as a substitute in data export/import.
///
/// The reference holds a key and its value that allows to uniquely identify the referenced object.
/// It doesn't have to an identifier, it can be any field that allows to uniquely identify the entity.
struct Reference: Codable {
    /// A name of the entity field to search. Must allow for unique entity identification.
    var key: String
    /// The `key` value that uniquely identifies the entity.
    var value: String
    
    /// Resolves the reference to an actual entity, if possible.
    ///
    /// Performs a standard `NSFetchRequest` to find the actual entity based on the `key` and `value` fields.
    /// In case of more than one record match will use the first one as a response.
    ///
    /// Referencing with the key/value approach allows to avoid creating additional fields (like a custom identifier) and
    /// additional logic. Instead it allows using the same database structure to reference the entities.
    ///
    /// - Parameters:
    ///   - _:                  Allows to specify the generic.
    ///   - context: Managed Object Context in which to perform resolution.
    ///
    /// - Returns: The referenced entity, if found.
    func resolve<Entity>(_: Entity.Type, inContext context: NSManagedObjectContext) -> Entity? where Entity: Referenceable & NSManagedObject {
        let predicate = NSPredicate(format: "%K == %@", key, value)
        let request = Entity.fetchRequest()
        request.entity = Entity.entity()
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first as? Entity
        } catch {
            Log().error("Unable to resolve a reference to \(Entity.self): \(error)")
        }
        return nil
    }
}


/// Identifiers an entity that contains references and requires to provide reference resolution method.
protocol ReferenceContainer {

    /// Resolves references by filling in the appropriate fields based on references.
    ///
    /// The implementation should account on the hierarchical references where applicable.
    func resolveReferences()
}


/// Allows an entity to be create references to itself by implementing `reference` property.
/// Only references to `Referenceable` entities can be resolved.
protocol Referenceable: NSManagedObject {
    /// A reference to the entity.
    var reference: Reference { get }
}
