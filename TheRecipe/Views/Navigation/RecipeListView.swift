//
//  ContentListView.swift
//  The Recipe
//
//FIXME: add EditButton()
import SwiftUI
import Foundation
import CoreData

struct RecipeListView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Binding var predicate: NSPredicate
    @State private var selectionForDelete: Recipe?
    @State private var searchQuery = ""
    @State private var showDeleteConfirmation = false

    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var appState:AppState
    @FetchRequest private var recipes: FetchedResults<Recipe>
    
    @FetchRequest(sortDescriptors: [
                                    SortDescriptor(\Tag.recipesCount, order: .reverse),
                                    SortDescriptor(\Tag.name, order: .forward),
                                   ],
                  predicate: NSPredicate(format: "%K > 0 OR %K > 0", #keyPath(Tag.recipesCount), #keyPath(Tag.dinnerMenusCount)))
    private var tags: FetchedResults<Tag>
    
    init( predicate: Binding<NSPredicate>) {
        
        _predicate = predicate
        
        _recipes = FetchRequest<Recipe>(
            sortDescriptors: [ SortDescriptor(\Recipe.lastModified, order: .reverse) ],
            predicate: predicate.wrappedValue,
                      animation: .default)
        
        _selectionForDelete =  State(initialValue:nil)
        _searchQuery =  State(initialValue:"")
        _showDeleteConfirmation =  State(initialValue:false)
        
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
            request.predicate = NSPredicate(format: "%K > 0 OR %K > 0", #keyPath(Tag.recipesCount), #keyPath(Tag.dinnerMenusCount))

            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \Tag.recipesCount, ascending: false),
                NSSortDescriptor(keyPath: \Tag.name, ascending: true)
            ]

            request.fetchLimit = 5
            
        _tags = FetchRequest(fetchRequest: request)
        
    }
    
    var body: some View {
        
        List( selection: $appState.selectedRecipe) {

            Section {
                ForEach(recipes) { recipe in
                    RecipeInListView(recipe: recipe)
                    
                        .tag(recipe)
                    
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                selectionForDelete = recipe
                                showDeleteConfirmation = true
                            }
                        }
                    
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                selectionForDelete = recipe
                                showDeleteConfirmation = true
                            }
                        }
                    
//                        .scrollContentBackground(.hidden)
                        .listRowBackground(Color.clear.background(.bar))
                }
            } header: {
                //FIXME: revert maybe later
//                if horizontalSizeClass == .compact {
//                    ScrollView(.horizontal){
//                        
//                        HStack {
//                            
//                            ForEach(tags){tag in
//                                
//                                Button(action: {
//                                    if isSelected(tag) {
//                                        appState.selectedTag = Selection<Tag>.allrecipes
//                                    } else {
//                                        appState.selectedTag = Selection<Tag>.one(tag)
//                                    }
//                                }) {
//                                    Label {
//                                        Text("#\(tag.wrappedName.capitalized) (\(tag.wrappedRecipes.count ))")
//                                            .font(.headline)
//                                    } icon: {
//                                        Image(systemName: "number.square.fill")
//                                            .foregroundColor(.accentColor)
//                                    }
//                                    .tag(Selection<Tag>.one(tag))
//                                }
//                                .conditionalButtonStyle(when: isSelected(tag), .borderedProminent, else: .bordered)
//                                
//                            }
//                        }
//                        .padding(.vertical)
//                        .labelStyle(.titleOnly)
//                    }
//                }
            }
            
        }
        .scrollContentBackground(.hidden)
#if os(macOS)
            .frame(minWidth:300)
            .toolbar {
                ToolbarItem(placement: .status) {
                    Button(action: newRecipe) {
                        Label("Add Recipe", systemImage: "square.and.pencil")
                    }
                }
            }
#else
            .listStyle( .insetGrouped)
            .toolbar {
                ToolbarItem {
                    Button(action: newRecipe) {
                        Label("Add Recipe", systemImage: "square.and.pencil")
                    }
                    .foregroundColor(.accentColor)
                }
            }
        
            
#endif
            .navigationTitle(appState.selectedTag?.title.localizedCapitalized ?? "")
            
            
            .searchable(text: $searchQuery, placement: .toolbar, prompt: "Search Recipes")
//            .contextMenu(forSelectionType: Recipe.self){ recipes in
//                Button("Delete", role: .destructive) {
//                    selection = recipes.first
//                    showDeleteConfirmation = true
//                }
//            }
            .alert(Text("Are you sure?", comment: "Recipe deletion confirmation alert title"), isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive, action: deleteSelectedRecipe)
            }
            .onChange(of: searchQuery) { query in
//                selectedTag = .all
                predicate = Recipe.predicate(forTaggedWith: appState.selectedTag, orMatching: query)
                recipes.nsPredicate = predicate
            }
            .onChange(of: appState.selectedTag) { value in
                predicate = Recipe.predicate(forTaggedWith: value)
                recipes.nsPredicate = predicate
            }
            .onAppear {
                predicate = Recipe.predicate(forTaggedWith: appState.selectedTag)
                recipes.nsPredicate = predicate
            }
        
    }
    
    func newRecipe() {
        let newRecipe = Recipe(context: viewContext)
//        selection = newRecipe
        appState.selectedRecipe = newRecipe
    }
    
    func deleteSelectedRecipe() {
        if let recipe = selectionForDelete {
            viewContext.delete(recipe)
        }
        selectionForDelete = nil
        appState.selectedRecipe = nil
    }
    
    func isSelected(_ tag: Tag) -> Bool {
        guard case let .one(t) = appState.selectedTag, t == tag else {
            return false
        }
        return true
    }
}


// MARK: -  Previews

#Preview {
        RecipeListView( predicate: .constant(Recipe.predicate(forTaggedWith: .allrecipes)))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AppState())
    
}


 struct RecipeInListView : View {
    @ObservedObject var recipe : Recipe
    
    var body: some View {
        VStack(alignment : .leading) {
            Text("\(recipe.wrappedTitle)")
                .font(.headline)
                //.fixedSize(horizontal: false, vertical: true)
            if (!recipe.wrappedSummary.isEmpty) {
                Text("\(recipe.wrappedSummary )")
                    .font(.subheadline)
                    .lineLimit(2, reservesSpace: true)
                    .fixedSize(horizontal: false, vertical: true)
            }
            TagsListView(provider: recipe)
            //TagCloudView(provider: recipe)
                .allowsHitTesting(false) //If hit testing is disallowed for a view, any taps automatically continue through the view on to whatever is behind it.
        }
        .contentShape(Rectangle())
        
        .badge( "\(recipe.rating)★")
#if os(macOS)
        .badgeProminence(.decreased)
        #endif
//        .overlay(alignment: .topTrailing) {
//            RatingViewShort(rating: recipe.rating)
//            
//        }
    }
}
