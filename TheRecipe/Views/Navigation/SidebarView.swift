//
//  Sidebar.swift
//  The Recipe
//

import SwiftUI

struct SidebarView: View {
//    @Binding var selection: Selection<Tag>?
    @State private var showSettings =  false
    @State private var tagToRemove: TagToRemove = .init(showConfirmation: false)
    @State private var selection: AutocompleteSelection<Tag> = .none
    @FetchRequest(sortDescriptors: [//SortDescriptor(\Tag.recipeModifiedDate, order: .reverse),
                                    SortDescriptor(\Tag.name, order: .forward),
                                    SortDescriptor(\Tag.recipesCount, order: .reverse),
                                   ],
                  predicate: NSPredicate(format: "%K > 0 OR %K > 0", #keyPath(Tag.recipesCount), #keyPath(Tag.dinnerMenusCount)))
    private var tags: FetchedResults<Tag>
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var appState:AppState
    var body: some View {
        VStack {
            if appState.recipesOnlyModeIsON {
                recipeSection
            } else {
                Picker("", selection: $appState.selectedFeature) {
                    
                    Text("Recipes")
                        .tag(ActiveFeature.recipe)
                    Text("Menus")
                        .tag(ActiveFeature.dinnerMenu)
                }
                .pickerStyle(.segmented)
                
                if appState.selectedFeature == .recipe {
                    recipeSection
                } else {
                    dinnerMenuSection
                }
            }
            
            HStack {
//                Button(action: {showAbout = true}) {
//                    Text("About", comment: "About button title")
//                }.buttonStyle(.borderedProminent)
//                    .foregroundColor(.white)
                Button(action: {showSettings = true}) {
                    Label("Settings", systemImage: "gearshape.fill")
                }.buttonStyle(.borderedProminent)
                //.foregroundColor(.white)
/*
                AutocompletedTextField(titleKey: "Pick!", selection: $selection) { text in
                    //DataSet
                    tags
                        .filter {
                            $0.wrappedName.lowercased().contains(text.lowercased())
                        }
                } item: { tag in
                    AutocompleterItem(autocompletedText: tag.wrappedName) {
                        Text(tag.wrappedName) //View in authocompleter list
                            .foregroundColor(.green)
                            .font(Font.body.bold())
                            .frame(maxWidth: .infinity)
                            .padding(0)
                            
                    }
                }*/
            }
        }
#if !os(macOS)
        .toolbar(.hidden)
#endif
        .navigationTitle("Tags")
        .alert(Text("Delete #\(tagToRemove.name)?", comment: "Tag deletion alert confirmation title"), isPresented: $tagToRemove.showConfirmation) {
            Button("Yes", role: .destructive) {
                guard let tag = tagToRemove.tag else {return}
                viewContext.delete(tag)
                Log().trace("Done")
            }
        } message: {
            VStack {
                Text("Your recipes will no longer be tagged #\(tagToRemove.name).", comment: "Tag deletion confirmation alert text")
                Text("Are you sure?", comment: "Tag deletion confirmation alert text")
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        .onChange(of: appState.selectedFeature) {newVal in
            appState.selectedTag =  appState.selectedFeature == .recipe ? .allrecipes : .alldinnermenus
            appState.selectedRecipe = nil
            appState.selectedDinnerMenu = nil
        }
//        .enableAutocompleterFields()
        //.applyStyle(MyAutocompleterStyle())
       
    }
    
    private var recipeSection : some View {
        

            List(selection: $appState.selectedTag) {
                
                Section {
                    
                    ForEach(tags.filter{$0.recipesCount > 0}, id: \.self) { tag in
                        Label {
                            Text("\(tag.wrappedName.capitalized) (\(tag.wrappedRecipes.count ))")
                        } icon: {
                            Image(systemName: "number.square.fill")
                                .foregroundColor(.accentColor)
                            
                        }
                        //FIXME: favorite tag feature
//                        .badge(tag.isFavorite ? "♥︎" : "♡")
                        .tag(Selection<Tag>.one(tag))
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive, action: {tagToRemove = .init(tag: tag)}) {
                                Text("Remove", comment: "Remove button title")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                tag.isFavorite = !tag.isFavorite
                                viewContext.saveChanges()
                            } label: {
                                if tag.isFavorite {
                                    Label("Un-Fav", systemImage: "flag")
                                        
                                } else {
                                    Label("Fav", systemImage: "flag.fill")
                                        
                                }
                                    
                            }
                        }

//                        .onLongPressGesture(perform: {
//                            tag.isFavorite = !tag.isFavorite
//                            viewContext.saveChanges()
//                            print("TODO: add/remove to fav tag")
//                        })
                    }
                } header: {
                    VStack(alignment:.leading, spacing: 15) {
                        Button(Selection<Tag>.allrecipes.title, systemImage: "folder.fill"){
                            appState.selectedTag = Selection<Tag>.allrecipes
                        }
                        .tag(Selection<Tag>.allrecipes)
                        
                        Button("Add New", systemImage: "square.and.pencil")  {
                            newRecipe()
                        }
                        .sectionHeaderStyle()
                    }
                    .labelStyle(.titleAndIcon)
                    .buttonStyle(.borderless)
                }
            }
        }
    
    private var dinnerMenuSection : some View {
        VStack {

            List(selection: $appState.selectedTag) {
                
                Section {
                    
                    ForEach(tags.filter{$0.dinnerMenusCount > 0}, id: \.self) { tag in
                        Label {
                            Text("\(tag.wrappedName.capitalized) (\(tag.wrappedDinnerMenus.count ))")
                        } icon: {
                            Image(systemName: "number.square.fill")
                                .foregroundColor(.accentColor)
                            
                        }
                        .tag(Selection<Tag>.one(tag))
                        .swipeActions {
                            Button(role: .destructive, action: {tagToRemove = .init(tag: tag)}) {
                                Text("Remove", comment: "Remove button title")
                            }
                        }
                    }
                } header: {
                    VStack(alignment:.leading, spacing: 15) {
                        Button( action: {appState.selectedTag = Selection<Tag>.alldinnermenus}) {
                            Label(Selection<Tag>.alldinnermenus.title, systemImage: "folder.fill")
                                .tag(Selection<Tag>.alldinnermenus)
                        }
                        
                        Button("Add New", systemImage: "square.and.pencil") {
                            newMenu() 
                        }
                        .sectionHeaderStyle()
                    }
                    .labelStyle(.titleAndIcon)
                    .buttonStyle(.borderless)
                    
                   
                }
            }
        }
    }
    func newRecipe() {
        let newRecipe = Recipe(context: viewContext)
        
        appState.selectedDinnerMenu = nil
        appState.selectedRecipe = newRecipe
        appState.selectedTag = Selection<Tag>.allrecipes
        print("add new recipe")
    }
                                       
    func newMenu() {
        
        let newMenu = DinnerMenu(context: viewContext)
        appState.selectedDinnerMenu = newMenu
        appState.selectedRecipe = nil
        appState.selectedTag = Selection<Tag>.alldinnermenus
        print("add new menu")
    }
}


// MARK: - Tag Removal Workaround


/// A workaround wrapper to allow tag removal from either swipe action or a context menu.
///
/// The `alert` modifier is intended to be used "in place" in order to capture the necessary parameters.
///
/// However, alert will only be displayed as long as the view it is attached to is visible.
///
/// This is not the case with swipe actions and context menu — the action disappears as soon as it is tapped.
///
/// This struct helps to encapsulate both required vars into a single structure to simplify it's usage in a view.
fileprivate struct TagToRemove {
    var tag: Tag?
    var showConfirmation = true
    
    var name: String {
        "\(tag?.wrappedName.localizedCapitalized ?? "")"
    }
}



struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        ViewPreview()
    }
    
    private struct ViewPreview: View {
        @StateObject private var state = AppState()
        
        var body: some View {
            SidebarView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(state)

        }
    }
}




