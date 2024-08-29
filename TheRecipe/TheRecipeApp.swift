//
//  The_RecipeApp.swift
//  The Recipe
//

import SwiftUI

/// Application alias to either UIApplication or NSApplication depending on platform.
#if os(macOS)
fileprivate typealias Application = NSApplication
#else
fileprivate typealias Application = UIApplication
#endif

var backgroundImage : some View {
    Image("bg-pattern")
    .resizable(resizingMode:.tile)
    .aspectRatio( contentMode: .fill)
    .opacity(0.20)
}

@main
struct The_RecipeApp: App {
    let persistenceController = PersistenceController.shared
    @State private var unrecoverableError: NSError?
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if let error = unrecoverableError {
                    ApplicationFailureView(error: error)
                } else {

                    RootView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
            }
            
            .foregroundStyle( Color("TextColor"), Color("TertiaryTextColor"))
            .onReceive(NotificationCenter.default.publisher(for: Application.willResignActiveNotification), perform: saveChanges)
            .onReceive(NotificationCenter.default.publisher(for: Application.willTerminateNotification), perform: saveChanges)
            .onReceive(NotificationCenter.default.publisher(for: PersistenceController.UnrecoverableErrorNotification)) { notification in
                if let error = notification.userInfo?[PersistenceController.UnrecoverableErrorKey] as? NSError {
                    unrecoverableError = error
                }
            }
        }
        .commands {
            SidebarCommands()
        }

    }
    
    private func saveChanges(_: Notification) {
        persistenceController.container.viewContext.saveChanges()
    }
}
