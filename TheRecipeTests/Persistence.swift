//
//  Persistence.swift
//  The Recipe
//

import CoreData
@testable import TheRecipe

struct PersistenceController {
    /// Core Data container.
    let container: NSPersistentContainer

    /// Special version of the ``PersistenceController`` used for Tests.
    /// Always in-memory.
    static var test: PersistenceController = {
        let result = PersistenceController()
        let viewContext = result.container.viewContext
        
        loadTestData(in: viewContext)
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    init() {
        container = NSPersistentContainer(name: "TheRecipe")
        container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}


fileprivate extension PersistenceController {
    static func loadTestData(in context: NSManagedObjectContext) {
       
    }
}

