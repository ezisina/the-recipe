//
//  EditingSheet.swift
//  TheRecipe
//

import SwiftUI
import CoreData

/// Universal sheet view for editing various content.
///
/// The view allows for editing newly created Core Data objects that are automatically deleted from the context in the case of user cancelation.
///
/// The object is considered modified as soon as user makes any change. Modified objects are saved upon sheet dismissal.
struct EditingSheet<Entity, Content>: View where Entity: NSManagedObject, Content: View {
    /// Entity to edit.
    ///
    /// You can create a new entity,inserted into context, and pass it here. It will be automatically deleted if user cancels the sheet without making changes.
    /// It will also be automatically saved after user changes on sheet dismissal.
    @ObservedObject private var entity: Entity
    
    /// Sheet title, displayed in the navigation bar.
    private let title: String
    
    /// Content view - the internal view that is presented in the sheet. You should work with the same object you passed as an ``entity``.
    private let content: Content
    
    /// A closure validating the sheet's data.
    private var validate: () -> Bool
    
    /// Closure that is executed when the entity is saved.
    private var onSave: () -> Void

    /// Closure that is executed when user cancels the sheet.
    private var onCancel: () -> Void

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var hasChanges = false
    @State private var shouldDeleteOnNoChange = false
    @State private var showValidationErrors = false
    
    /// Provides title for the Close button based on whether or not user has made any changes.
    private var dismissButtonTitle: String {
        if hasChanges {
            return NSLocalizedString("Save", comment: "Dismiss button title in the cooking step editing sheet.")
        } else {
            return NSLocalizedString("Cancel", comment: "Dismiss button title in the cooking step editing sheet.")
        }
    }
    
    /// Creates a new sheet instance with the given parameters.
    ///
    /// - Parameters:
    ///   - title:    Title.
    ///   - entity:   Entity to observe for changes.
    ///   - content:  Content view - the internal view that is presented in the sheet.
    ///   - validate: Validation closure - must return true if the entity contains all valid data and can be saved. Optional.
    ///   - onSave:   Closure to execute on entity save. Closure is executed before the context is saved.
    ///   - onCancel: Closure to execute on cancel. Closure is executed before the entity is deleted (if applicable).
    init(_ title: String, editing entity: Entity, @ViewBuilder content: () -> Content, validate: @escaping () -> Bool = { true }, onSave: @escaping () -> Void = {}, onCancel: @escaping () -> Void = {}) {
        self.title = title
        self.entity = entity
        self.content = content()
        self.onSave = onSave
        self.onCancel = onCancel
        self.validate = validate
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title3)
                Spacer()
                Button(dismissButtonTitle, action: applyChanges)
                    .foregroundColor(.accentColor)
            }
            .padding()
            .alert("Oops", isPresented: $showValidationErrors) {
            } message: {
                Text("Please fill in all the required fields", comment: "Fill in all the required fields")
            }
            
            content
        }
        .onReceive(entity.objectWillChange) { _ in
           // print(entity.isUpdated, entity.hasChanges, entity.hasPersistentChangedValues)
            print("form hasChanges", entity)
            hasChanges = true
        }
        .onAppear {
            shouldDeleteOnNoChange = entity.objectID.isTemporaryID
        }
        .onDisappear {
            let validateRes = validate()
            print("\(validateRes) \(shouldDeleteOnNoChange) \(hasChanges)") //true true false
            if (!validateRes) || (shouldDeleteOnNoChange && !hasChanges) {
                print("form cancel")
                onCancel()
                //do not delete, because it's editing mostly
               // viewContext.delete(entity)
            } else if hasChanges {
                print("form save")
                onSave()
                viewContext.saveChanges()
            } else {
                print("form cancel")
                onCancel()
            }
        }
    }
    
    private func applyChanges() {
        guard !hasChanges || validate() else {
            showValidationErrors = true
            return
        }
        dismiss()
    }
}
