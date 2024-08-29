//
//  NSManagedObjectContext+Extensions.swift
//  The Recipe
//

import CoreData


extension NSManagedObjectContext {
    
    /// Saves context changes without throwing an error.
    ///
    /// Errors that may  occurs during the save will be automatically logged.
    ///
    /// - Returns: True if context save is successful, false otherwise.
    @discardableResult
    func saveChanges() -> Bool {
        do {
            try save()
            return true
        } catch {
            Log().critical("Error saving context: \(error)")
        }
        return false
    }
    
    
    /// Exports the entire data stored in the context to a JSON data.
    ///
    /// Any errors are logged automatically. `nil` is returned on error.
    ///
    /// - Returns: JSON data, if the export is possible.
    func export() -> Data? {
        do {
            return try JSONEncoder().encode(DataRoot(inContext: self))
        } catch {
            Log().error("Error exporting data store - \(error)")
        }
        return nil
    }
    
    /// Imports the data from the given JSON into the context.
    ///
    /// The method **does not** clear the context and will attempt to add the data to the context.
    ///
    /// - Parameter data: JSON data to import.
    /// 
    /// - Returns: True on success, false on failure. Errors are logged automatically.
    @discardableResult
    func `import`(from data: Data) -> Bool {
        do {
            let decoder = JSONDecoder()
            decoder.userInfo[.managedObjectContext] = self
            let dataRoot = try decoder.decode(DataRoot.self, from: data)
            dataRoot.resolveReferences()
            return true
        } catch {
            Log().error("Error importing data store - \(error)")
        }
        return false
    }
}
