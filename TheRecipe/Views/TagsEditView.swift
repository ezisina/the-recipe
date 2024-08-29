//
//  RecipesTagsView.swift
//  TheRecipe
//
//  Created by Elena Zisina on 12/13/22.
//

import SwiftUI
struct TagsEditView<Provider>: View where Provider: ObservableObject, Provider: TagProvider {
    @ObservedObject var provider: Provider
//struct TagsEditView: View {
//    @ObservedObject var recipe: Recipe
    @State private var tagToRemove: TagToRemove = .init(showConfirmation: false)
    let columns = [GridItem(.adaptive(minimum:100)),
                   GridItem(.adaptive(minimum:100)),
                   GridItem(.adaptive(minimum:100))]
    /*
    var tags = ["Appetizers", "Barbecue & Grilling", "Beans & Legumes", "Breads", "Breakfast", "Chicken & Poultry", "Condiments & Sauces", "Spices","Drinks", "Eggs & Cheese", "Fish", "Grains & Seeds", "Herbs", "Meat", "One Dish Meals", "Pasta", "Rice", "Salads & Dressings", "Snacks", "Soups & Stews", "Vegetables", "Vegetarian", "Sweets", "Canning & Preserving", "Cakes", "Cookies & Candy", "Desserts", "Fruit", "Frozen Treats", "Muffins", "Pancakes & Crepes", "Pies & Tarts"]
    */
    
    @State private var searchQuery : String = ""
    
    @FetchRequest(sortDescriptors: [ SortDescriptor(\Tag.name, order: .forward) ], predicate: NSPredicate(value: true), animation: .default)
    private var tags: FetchedResults<Tag>
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.isSearching) private var isSearching
    
    var body: some View {
        NavigationStack{
            
            TagsListView(provider: provider)
                .padding(.horizontal)
                ScrollView {
                    
                    LazyVGrid(columns: columns) {
                        ForEach(tags) { value in
                            //FIXME: tap on selected tag remove from selected. tap on tag from alltaglist remove from tag list and add to selected tags
                            TagInGrid(title: value, isSelected: provider.wrappedTags.contains(value))
                                .onTapGesture {
                                    if provider.wrappedTags.contains(value) {
                                        provider.removeFromTags(value)
                                    } else {
                                        provider.addToTags(value)
                                    }
                                    searchQuery = ""
                                }
                                .onLongPressGesture(perform: {
                                    tagToRemove = .init(tag: value)})
                            
                        }
                    }
                }
                .padding()
                .navigationTitle("Tags")
            Text("This is the full list of Tags. If it hasn't any suitable for the recipe, put any tag in search and Enter. The new tag will be added to the Tags.")
                .noteStyle()
                .padding()

            }
            .searchable(text: $searchQuery, prompt: "Search Tags")
            .onSubmit(of: .search) {
                let tag = Tag(context: viewContext)
                tag.name = searchQuery
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .lowercased()
                tag.managedObjectContext?.saveChanges()
                
                searchQuery = ""
               
            }
            .onChange(of: searchQuery) { query in
                tags.nsPredicate =
                query.isEmpty
                        ? nil
                        : NSPredicate(format: "%K contains[cd] %@", #keyPath(Tag.name), query)
            }
            .alert(Text("Delete #\(tagToRemove.name)?", comment: "Tag deletion alert confirmation title"), isPresented: $tagToRemove.showConfirmation) {
                Button("Yes", role: .destructive) {
                    deleteTag()
                    Log().trace("Done")
                }
            } message: {
                VStack {
                    Text("Your recipes will no longer be tagged #\(tagToRemove.name).", comment: "Tag deletion confirmation alert text")
                    Text("Are you sure?", comment: "Tag deletion confirmation alert text")
                }
            }
            
        
    }
    
    func deleteTag() {

        guard let tag = tagToRemove.tag else {return}
        viewContext.delete(tag)
    }

}

#Preview {
    TagsEditView(provider: Recipe.firstForPreview())
}

struct TagInGrid : View {
    var title : Tag
    var isSelected : Bool
    var body: some View {
        HStack(alignment: .center) {
            Text("\(title.wrappedName.localizedCapitalized)")
                .font(.callout)
                .fontWeight(.semibold)
            
        }
        .frame(width: 100, height: 50, alignment: .center)
        .foregroundColor(.primary)
        .background(isSelected ? .accentColor.opacity(0.5) : Color.secondary.opacity(0.5))
        .cornerRadius(8)
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
    var toRemove = false
    var name: String {
        "\(tag?.wrappedName.localizedCapitalized ?? "")"
    }
}
