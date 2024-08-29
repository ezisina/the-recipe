//
//  DinnerMenuList.swift
//  TheRecipe
//
//  Created by Elena Zisina on 7/12/23.
//

import SwiftUI

struct DinnerMenuList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var appState:AppState
    @FetchRequest private var menus: FetchedResults<DinnerMenu>
    @State private var selectionForDelete: DinnerMenu?
    @State private var searchQuery = ""
    @State private var showDeleteConfirmation = false
    
    //FIXME: add search 
    init(/*selectedTag: Binding<Selection<Tag>?>, predicate: Binding<NSPredicate>, selection : Binding<Recipe?>*/) {
//        _selectedTag = selectedTag //?? .all
//        _selection = selection
        
//        _predicate = predicate
        
        _menus = FetchRequest<DinnerMenu>(
            sortDescriptors: [ SortDescriptor(\DinnerMenu.title, order: .reverse) ],
            predicate: NSPredicate(value: true),//predicate.wrappedValue,
                      animation: .default)
        
        _selectionForDelete =  State(initialValue:nil)
//        _searchQuery =  State(initialValue:"")
        _showDeleteConfirmation =  State(initialValue:false)
    }
    
    var body: some View {
        List(menus, selection: $appState.selectedDinnerMenu) { item in
            MenuInListView(menu: item)
                    .tag(item)
                    .swipeActions {
                        Button("Delete", role: .destructive) {
                            selectionForDelete = item
                            showDeleteConfirmation = true
                        }
                    }
                    .scrollContentBackground(.hidden)
            }
        
        .tint(Color.accentColor)
        .navigationTitle(appState.selectedTag?.title ?? "")
#if os(macOS)
            .frame(minWidth:300)
            .toolbar {
                ToolbarItem(placement: .status) {
                    Button(action: newMenu) {
                        Label("Add Menu", systemImage: "square.and.pencil")
                    }
                }
            }
#else
            .listStyle( .insetGrouped)
            .toolbar {
                ToolbarItem {
                    Button(action: newMenu) {
                        Label("Add Menu", systemImage: "square.and.pencil")
                    }
                    .foregroundColor(.accentColor)
                }
            }
        
#endif
            .alert(Text("Are you sure?", comment: "Menu deletion confirmation alert title"), isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive, action: deleteSelectedItem)
            }
    }
    func newMenu() {
        
        let newMenu = DinnerMenu(context: viewContext)
        appState.selectedDinnerMenu = newMenu
        appState.selectedRecipe = nil
        appState.selectedTag = Selection<Tag>.alldinnermenus
        print("add new menu")
    }
    
    func deleteSelectedItem() {
        if let recipe = selectionForDelete {
            viewContext.delete(recipe)
        }
        selectionForDelete = nil
    }
}

#Preview {
    DinnerMenuList()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AppState())

}

struct MenuInListView : View {
   @ObservedObject var menu : DinnerMenu
   
   var body: some View {
       VStack(alignment : .leading) {
           Text("\(menu.wrappedName)")
               .font(.headline)
               
           Text("\(menu.wrappedDescription )")
               .font(.subheadline)
               .foregroundStyle(.secondary)
//           TagsListView(recipe: recipe)
//               .foregroundColor(.secondary)
       }.overlay(alignment: .topTrailing) {
//           RatingViewShort(rating: recipe.rating)
//               .tint(.secondary)
//               .foregroundStyle(.secondary)
           
       }
   }
}
