//
//  RootView.swift
//  TheRecipe
//
//  Created by Elena Zisina on 8/14/23.
//

import SwiftUI


/// The main navigational view everything begins with.
///
/// Sets up NavigationView and provides necessary bindings.
struct RootView: View {
    @State private var navColumns: NavigationSplitViewVisibility = .automatic
    @StateObject private var appState = AppState()
    @State private var displayPredicate = Recipe.predicate(forTaggedWith: .allrecipes)
    @State private var path = NavigationPath()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @FetchRequest(sortDescriptors: [//SortDescriptor(\Tag.recipeModifiedDate, order: .reverse),
                                    SortDescriptor(\Tag.name, order: .forward),
                                    SortDescriptor(\Tag.recipesCount, order: .reverse),
                                   ],
                  predicate: NSPredicate(format: "%K > 0 OR %K > 0", #keyPath(Tag.recipesCount), #keyPath(Tag.dinnerMenusCount)))
    private var tags: FetchedResults<Tag>

    var body: some View {
        
            NavigationSplitView(columnVisibility: $navColumns) {
                SidebarView()
                    .padding()
                    .scrollContentBackground(.hidden)
                    .background( backgroundImage.ignoresSafeArea())
                #if os(macOS)
                    .frame(minWidth: 200, maxWidth: 300, minHeight: 300, alignment: .leading)
                #endif
                    .environmentObject(appState)
            } content: {
                if appState.selectedFeature == .recipe {
                    RecipeListView(/*selectedTag: $selectedTag,*/ predicate: $displayPredicate/*, selection: $selectedRecipe*/)
                        .scrollContentBackground(.hidden)
                        .background( backgroundImage.ignoresSafeArea())
                        .environmentObject(appState)
                } else {
                    DinnerMenuList()
                        .scrollContentBackground(.hidden)
                        .background( backgroundImage.ignoresSafeArea())
                        .environmentObject(appState)
                }

            } detail: {
                DetailView()
                    .background( backgroundImage.ignoresSafeArea())
                    .environmentObject(appState)
            }
            .onAppear {
                if nil == appState.selectedRecipe && nil == appState.selectedDinnerMenu {
                    
                    if horizontalSizeClass == .compact {
                        navColumns = .automatic
                    } else {
                        navColumns = .doubleColumn
                    }
                } else {
                    navColumns = .detailOnly
                    
                }
            }
            .onChange(of: appState.selectedRecipe) {value in
                if nil == value && nil == appState.selectedDinnerMenu {
                    navColumns = .automatic
                } else {
                    if horizontalSizeClass == .compact {
                        navColumns = .detailOnly
                    } else {
                        navColumns = .automatic
                    }
                }
            }
            .onChange(of: appState.selectedDinnerMenu) {value in
                if nil == value && nil == appState.selectedRecipe{
                    navColumns = .automatic
                } else {
                    if horizontalSizeClass == .compact {
                        navColumns = .detailOnly
                    } else {
                        navColumns = .automatic
                    }
                }
            }
#if os(macOS)
            .frame(minWidth: 700, minHeight: 300)
#endif
       
    }
}




#Preview {
    RootView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)

}


//MARK: - Enviroment

@MainActor class AppState : ObservableObject {
    @Published var selectedTag: Selection<Tag>? = .allrecipes {
        willSet {
            print("changed selectedTag to \(newValue ?? .none)")
            objectWillChange.send()
        }
    }
    @Published var selectedRecipe: Recipe?
    @Published var selectedDinnerMenu: DinnerMenu?
    @Published var selectedFeature : ActiveFeature = .recipe
//    @Published var displayPredicate = Recipe.predicate(forTaggedWith: .all)
    //FIXME: Add recipesOnlyModeIsON to UserDefaults
    @Published var recipesOnlyModeIsON = true
    
    func resetState() {
        selectedTag = .allrecipes
        selectedRecipe = nil
        selectedDinnerMenu = nil
        selectedFeature = .recipe
    }
}

enum ActiveFeature : Int {
case recipe, dinnerMenu
}
