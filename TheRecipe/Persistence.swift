//
//  Persistence.swift
//  The Recipe
//

import CoreData

struct PersistenceController {
    /// A notification name that is sent if an unrecoverable error occurs during the initialization of the store.
    /// Notification will include NSError in userInfo, keyed as ``UnrecoverableErrorKey``.
    static let UnrecoverableErrorNotification = Notification.Name("unrecoverable_error_notification")
    
    /// The key name in the userInfo object posted with the ``UnrecoverableErrorNotification``.
    static let UnrecoverableErrorKey = "unrecoverable_error"

    /// Shared instance of the ``PersistenceController``.
    static let shared = PersistenceController()
    
    /// Core Data container.
    let container: NSPersistentCloudKitContainer

    /// Special version of the ``PersistenceController`` used for Canvas Previews.
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        #if DEBUG
            let url = Bundle.main.url(forResource: "preview_db", withExtension: "json")!
            let data = try! Data(contentsOf: url)
            viewContext.import(from: data)
        #endif
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Self.UnrecoverableErrorNotification,
                    object: nil,
                    userInfo: [Self.UnrecoverableErrorKey: nsError]
                )
            }
        }
        return result
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "TheRecipe")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: Self.UnrecoverableErrorNotification,
                        object: nil,
                        userInfo: [Self.UnrecoverableErrorKey: error]
                    )

                }
            }
        })
    }
}
