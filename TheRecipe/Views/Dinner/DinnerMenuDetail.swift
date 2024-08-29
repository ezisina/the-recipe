//
//  DinnerMenuDetail.swift
//  TheRecipe
//
//  Created by Elena Zisina on 7/12/23.
//
/*https://www.webstaurantstore.com/blog/2578/full-course-meal.html
 12 course meal: A 12 course dinner menu includes an hors d'oeuvre, amuse-bouche, soup, appetizer, salad, fish, first main course, palate cleanser, second main course, cheese course, dessert, and mignardise.
 10 course meal: A 10 course dinner menu includes an hors d'oeuvre, soup, appetizer, salad, fish, main course, palate cleanser, second main course, dessert, and mignardise.
 9 course meal: A 9 course dinner menu includes an hors d'oeuvre, soup, appetizer, salad, fish, main course, palate cleanser, dessert, and mignardise.
 8 course meal: An 8 course dinner menu includes an hors d'oeuvre, soup, appetizer, salad, main course, palate cleanser, dessert, and mignardise.
 7 course meal: A 7 course dinner menu includes an hors d'oeuvre, soup, appetizer, salad, main course, dessert, and mignardise.
 6 course meal: A 6 course dinner menu includes an hors d'oeuvre, soup, appetizer, salad, main course, and dessert.
 5 course meal: A 5 course dinner menu includes an hors d'oeuvre, appetizer, salad, main course, and dessert.
 4 course meal: A 4 course dinner menu includes an hors d'oeuvre, appetizer, main course, and dessert.
 3 course meal: A 3 course dinner menu includes an appetizer, main course, and dessert.
 */

import SwiftUI
import CoreData

enum CoarseMealType: String, CaseIterable, Identifiable {
    case threeCM = "3"
    case fourCM = "4"
    case fiveCM = "5"
    case sixCM = "6"
    case sevenCM = "7"
    case eightCM = "8"
    case nineCM = "9"
    case tenCM = "10"
    case twelveCM = "12"

    var id: Self { self }
    var coarses : [MealType] {
        switch self {
        case .threeCM: return [.appetizer, .firstMain, .dessert]
        case .fourCM: return [.horsdoeuvre, .appetizer, .firstMain, .dessert]
        case .fiveCM: return [.horsdoeuvre, .appetizer, .salad, .firstMain, .dessert]
        case .sixCM: return [.horsdoeuvre, .soup, .appetizer, .salad, .firstMain, .dessert]
        case .sevenCM: return [.horsdoeuvre, .soup, .appetizer, .salad, .firstMain, .dessert, .mignardise]
        case .eightCM: return [.horsdoeuvre, .soup, .appetizer, .salad, .firstMain,.palateCleanser, .dessert, .mignardise]
        case .nineCM: return [.horsdoeuvre, .soup, .appetizer, .salad, .fish, .firstMain,.palateCleanser, .dessert, .mignardise]
        case .tenCM: return [.horsdoeuvre, .soup, .appetizer, .salad, .fish, .firstMain,.palateCleanser, .secondMainCourse, .dessert, .mignardise]
        case .twelveCM: return [.horsdoeuvre, .soup, .appetizer, .salad, .fish, .firstMain, .palateCleanser, .secondMainCourse, .cheeseCourse, .dessert, .mignardise]
        }
    }

}
//Order of the types matters.
enum MealType: Int, CaseIterable, Identifiable, Comparable {
    case horsdoeuvre
    case amusebouche
    case soup
    case appetizer
    case salad
    case fish
    case firstMain
    case palateCleanser
    case secondMainCourse
    case cheeseCourse
    case dessert
    case mignardise
    
    var id: Int { self.rawValue }
    
    static func < (lhs: MealType, rhs: MealType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    var name: String {
        switch self {
            case .horsdoeuvre: return "hors d'oeuvre"
            case .amusebouche:  return "amuse-bouche"
            case .soup:  return "soup"
            case .appetizer:  return "appetizer"
            case .salad:   return "salad"
            case .fish:  return "fish"
            case .firstMain:  return "Main Course"
            case .palateCleanser: return  "palate Cleanser"
            case .secondMainCourse: return "second Main Course"
            case .cheeseCourse: return  "Cheese course"
            case .dessert: return  "dessert"
            case .mignardise:  return "mignardise"
        }
    }
    
    var localizedDescription: String {
        switch self {
            case .horsdoeuvre: return "Hors d’oeuvres are usually finger foods that can be held in the hand. This course is typically served during a cocktail hour or as guests are arriving."
            case .amusebouche:  return "This might serve to stimulate the appetite or simply hint at flavors to come in the next meal course(s). In restaurants, this is normally a complimentary item specifically chosen by the chef."
            case .soup:  return "A classic idea is to relate your soup course to the season. It's always smart to avoid soups that are too hearty so guests don’t fill up for the rest of the meal."
            case .appetizer:  return "This course is referred to as the entree because it introduces the main courses in the meal. It is usually served on serving trays or small appetizer plates and features small cuts of meat, seasonal vegetables, starches, and sauces."
            case .salad:   return "salad"
            case .fish:  return "This dish is a flavorful light protein before the main courses."
            case .firstMain:  return "The first main dish is often white meat, such as chicken, duck, or turkey."
            case .palateCleanser: return  "This is like a reset for your taste buds. Its purpose is to remove residual tastes from the mouth before the next course."
            case .secondMainCourse: return "The second main course is red meat, such as premium beef and lamb, or game meat such as venison."
            case .cheeseCourse: return  "Create a platter of different cheeses along with items to accompany them."
            case .dessert: return  "Usually accompanied by an after-dinner drink such as a glass of dessert wine, coffee, or tea, this is a sweet and decadent course."
            case .mignardise:  return "At the end of the meal, you can serve a mignardise, which is a tiny, bite-sized dessert or pastry served with tea, coffee, port, brandy, or scotch."
        }
    }
}

struct DinnerMenuDetail: View {
    @ObservedObject var dinnerMenu : DinnerMenu
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.managedObjectContext) private var viewContext
    
//    @State private var pickedRecipe: Recipe
//    @FetchRequest(sortDescriptors: [ SortDescriptor(\Recipe.lastModified, order: .forward) ], predicate: NSPredicate(value: true), animation: .default)
//    private var recipes : FetchedResults<Recipe>
    
    @FetchRequest(sortDescriptors: [ .init(keyPath: \Recipe.title, ascending: true) ], predicate: .init(value: false))
    private var matchingRecipes: FetchedResults<Recipe>
    
    
    @State private var searchQuery = ""
    @State private var multiSelectionRecipes = Set<Recipe>()
    
    @State private var dinnerItemTextField = ""
    
    @State private var selectedCoarseMealType: CoarseMealType = .threeCM
    
    @State private var formFields : [MealType: AutocompleteSelection<Recipe>] = [
        .horsdoeuvre: .none,
        .amusebouche: .none,
        .soup: .none,
        .appetizer: .none,
        .salad: .none,
        .fish: .none,
        .firstMain: .none,
        .palateCleanser: .none,
        .secondMainCourse: .none,
        .cheeseCourse: .none,
        .dessert: .none,
        .mignardise: .none,
    ]
    @State private var filteredFormFields : [MealType: AutocompleteSelection<Recipe>] = [
        .horsdoeuvre: .none,
        .amusebouche: .none,
        .soup: .none,
        .appetizer: .none,
        .salad: .none,
        .fish: .none,
        .firstMain: .none,
        .palateCleanser: .none,
        .secondMainCourse: .none,
        .cheeseCourse: .none,
        .dessert: .none,
        .mignardise: .none,
    ]
    
    
    
    @State private var showTagsPicker = false
//    @State private var test: AutocompleteSelection<Recipe> = .none
    @State private var popupTagPresented = false
    @State private var tagText = ""
    @State private var recipeForPreview : Recipe? = nil
    @FetchRequest(sortDescriptors: [ SortDescriptor(\Tag.name, order: .forward) ], predicate: NSPredicate(value: true), animation: .default)
    private var tags: FetchedResults<Tag>
    
    
    
    var body: some View {
        let layout = horizontalSizeClass == .regular ? AnyLayout(HStackLayout(alignment: .top, spacing: 4)) : AnyLayout(VStackLayout(alignment:.leading, spacing: 4))

        List {
            Section {

                // Summary
                VStack(alignment:.leading, spacing: 0) {
                    RecipeTextEditingView(entity: $dinnerMenu.wrappedName, placeholder: "Dinner Menu Title")
                    
                    //Divider()
                    Text("Title:", comment: "DinnerMenu Title TextEdit title")
                        .noteStyle()
                    
                }
                //.listRowBackground( rowColor )
                
                //Description
                VStack(alignment:.leading, spacing: 0) {
                    RecipeTextEditingView(entity: $dinnerMenu.wrappedDescription, placeholder: "Dinner Menu Description")
                    Divider()
                    Text("Description:", comment: "DinnerMenu Description TextEdit title")
                        .noteStyle()
                    
                }
                //Source URL OR AUthor
                VStack(alignment:.leading, spacing: 0) {
                    RecipeTextEditingView(entity: $dinnerMenu.wrappedSource, placeholder: "Source or author")
                    Divider()
                    Text("Source or author:", comment: "DinnerMenu Source or author TextEdit title")
                        .noteStyle()
                    
                }
                //Course Meal Count selector
                VStack(alignment: .center) {
                    Picker("Dinner type", selection: $selectedCoarseMealType) {
                           ForEach(CoarseMealType.allCases) { type in
                               
                               Text(type.rawValue.capitalized)
                                   .tag(type.rawValue)
                           }
                       }
                    .pickerStyle(.segmented)
                    Divider()
                    Text("How many courses your menu has: ", comment: "DinnerMenu Course Meal title")
                        .noteStyle()
                }

                VStack {
                    ForEach(Array(filteredFormFields.keys.sorted())) { mealType  in
                       // GeometryReader { geometry in
                            layout {
                                
                                Text(mealType.name.capitalized)
                                    .sectionHeaderStyle()
                                    //.fixedSize(horizontal: true, vertical: true)
                                   // .frame(width: geometry.size.width * 0.35, alignment: .trailing)
                                    .frame(alignment: horizontalSizeClass == .regular ? .leading : .trailing)
                                RecipeAutocompletedField(selection: binding(to: mealType))
                                   // .fixedSize(horizontal: true, vertical: true)
                                  //  .frame(width: geometry.size.width * 0.65)
                                    .frame(alignment: horizontalSizeClass == .regular ?  .trailing : .leading)
                                
                            }
                            .frame(maxWidth: .infinity)
                            .overlay(alignment:.topTrailing) {
                                
                                if case let .item(recipe) = formFields[mealType] {
                                    
                                    Button("View", systemImage:"arrow.right"){
                                        print("todo: go to the recipe", recipe.debugDescription)
                                        recipeForPreview = recipe
                                        
                                    }
                                    .labelStyle(.iconOnly)
                                    .buttonStyle(.bordered)
                                } else if case .plainText(let title) = formFields[mealType] {
                                    Button("Create", systemImage: "plus"){
                                        print("todo: create recipe w title and dinnerMenuItem", title)
                                        recipeForPreview = Recipe(context: viewContext)
                                        recipeForPreview?.wrappedTitle = title

                                    }
                                    .labelStyle(.iconOnly)
                                    .buttonStyle(.bordered)
                                } else {
                                    EmptyView()
                                }
                            }
//                        }
                            
                    }

                }
            }
            .listSectionSeparator(.hidden)
            .listRowSeparator(.hidden)
            .headerProminence(.standard)
            
            /*
             if case let .item(recipe) = formFields[mealType] {
                 
                 Button("View", image: "arrow.right.circle.fill") {
                     print("todo: go to the recipe", recipe.debugDescription)
                     recipeForPreview = recipe
                 }
//                                    .labelStyle(.iconOnly)
//                                    .buttonStyle(.bordered)
             }
//                                else if let .plainText(title) = formFields[mealType] {
//                                    Button("Create", image: "plus.circle.fill"){
//                                        print("todo: create recipe w title and dinnerMenuItem", title)
//                                        recipeForPreview = Recipe(context: viewContext)
//                                        //recipeForPreview?.wrappedTitle = title
//
//                                    }
//                                    .labelStyle(.iconOnly)
//                                    .buttonStyle(.bordered)
//                                }
             else {
                 EmptyView()
             }
             */
//MARK: - Tags
            Section {
                VStack {
                    TagCloudView(provider: dinnerMenu)
                        .onTapGesture(perform: { showTagsPicker = true })
                        .listRowBackground( Color.clear )
                    TagsAutocompleterView( provider: dinnerMenu)

                }
            } header: {
                tagsHeader
            }
            
           
        }
//        .onChange(of: searchQuery) { query in
//            let predicate = Recipe.predicate(forTaggedWith: .all, orMatching: query)
//
//            recipes.nsPredicate =
//            query.isEmpty
//                    ? nil
//                    : predicate
//        }
#if !os(macOS)
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .scrollContentBackground(.hidden)
        .navigationTitle($dinnerMenu.wrappedName)
        .toolbar {
            
            Button("Save", systemImage: "square.and.arrow.down") {
                saveDinnerMenu()
            }
            .buttonStyle(.borderless)
            .labelStyle(.titleOnly)
            .foregroundColor(.accentColor)
        }
        .sheet(isPresented: $showTagsPicker) {
            TagsEditView(provider: dinnerMenu)
        }
        .sheet(item: $recipeForPreview){ recipe in
            if recipe.isInProgress {
                RecipeView(recipe: recipe)
            } else {
                RecipePreviewView(recipe: recipe)
            }
        }

        .onAppear {
            selectedCoarseMealType = coursesByItemsCount
            print("onAppear \(selectedCoarseMealType)")
            for item in dinnerMenu.wrappedDinnerMenuItems.ordered {
                if let recipe = item.recipe {
                    formFields[MealType(rawValue: item.wrappedOrder)!] = .item(recipe)
                } else {
                    formFields[MealType(rawValue: item.wrappedOrder)!] = .plainText(item.wrappedName)
                }
            }
            filteredFormFields = formFields.filter{selectedCoarseMealType.coarses.contains($0.key)}
        }
        .onChange(of: selectedCoarseMealType) { newVal in
            filteredFormFields = formFields.filter{newVal.coarses.contains($0.key)}
        }
        
    }
    
    var coursesByItemsCount: CoarseMealType {
        switch dinnerMenu.dinnerMenuItems?.count ?? 3 {
            case 3 : return .threeCM
            case 4 : return .fourCM
            case 5 : return .fiveCM
            case 6 : return .sixCM
            case 7 : return .sevenCM
            case 8 : return .eightCM
            case 9 : return .nineCM
            case 10 : return .tenCM
            case 12 : return .twelveCM
            default : return .threeCM
        }
        
    }
    private var tagsHeader: some View {
        LabeledContent {
            Button(action: { showTagsPicker = true }) {
                Label("Edit Tags", systemImage: "plus")
                    .labelStyle(.iconOnly)
            }.foregroundColor(.accentColor)
        } label: {
            Text("Tags")
                .sectionHeaderStyle()
        }
    }
    //FIXME: make dinnermenuitem as selection
    func saveDinnerMenu() {
        dinnerMenu.wrappedDinnerMenuItems.removeAll()
        for mealType in formFields {

            switch mealType.value {
                
            case .none:
                break
            case .plainText(let text):
                print(text)
                let dinnerMenuItem = DinnerMenuItem.findOrNew(text, by: \.title, inContext: viewContext)
                dinnerMenuItem.order = Int16(mealType.key.rawValue)
                dinnerMenuItem.title = text
                dinnerMenu.addToDinnerMenuItems(dinnerMenuItem)

            case let .item(recipe):
                print(recipe.title ?? "NA")
                let dinnerMenuItem = DinnerMenuItem.findOrNew(recipe, by: \.recipe, inContext: viewContext)
                dinnerMenuItem.order = Int16(mealType.key.rawValue)
                dinnerMenuItem.title = recipe.title
                dinnerMenuItem.summary = recipe.summary
                dinnerMenu.addToDinnerMenuItems(dinnerMenuItem)

            }
            
            //print( mealType.key, mealType.key.rawValue,  mealType.value)
        }
        let tagMenu = Tag.findOrNew("dinner Menu", by: \.name, inContext: viewContext)
        dinnerMenu.addToTags(tagMenu)
        
//        print(dinnerMenu)
        if dinnerMenu.hasChanges || dinnerMenu.hasPersistentChangedValues {
            print("DinnerMenu saved changes")
            viewContext.saveChanges()
        } else {
            print("Nothing changed in DinnerMenu. Skip save changes")
        }
      //  dinnerMenu.addToDinnerMenuItems(dinnerMenuItem)
    }
    func binding(to type: MealType) -> Binding<AutocompleteSelection<Recipe>> {
        .init {
            formFields[type] ?? .none
        } set: { value in
            formFields[type] = value
        }
    }
}

// MARK: - Autocompleter. FIXME: Has to be moved out from here

enum AutocompleteSelection<T>: Hashable, Equatable where T: Hashable, T: Equatable {
    case none
    case plainText(String)
    case item(T)
}

struct AutocompleteView2<T>: View where T: NSFetchRequestResult, T: Hashable, T: Identifiable {
    @Binding var selection : AutocompleteSelection<T>
    var itemTitle: KeyPath<T,String>
    var prompt = ""
    var fetchBuilder: (String) -> NSFetchRequest<T>
    @State private var inputText = ""
    @State private var foundItems:FoundItems<T>?
    @Environment(\.managedObjectContext) private var viewContext
    var isPickerShown: Bool {
        switch selection {
        case .none:
            return !inputText.isEmpty
        case .plainText(let string) where !inputText.isEmpty:
            return string != inputText
        case .item(let t) where !inputText.isEmpty:
            return t[keyPath: itemTitle] != inputText
        default:
            return false
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TextField("", text: $inputText, prompt: Text(prompt))

                .onChange(of: inputText, perform:  { searchText in
                    guard isPickerShown else {
                        if inputText.isEmpty {
                            selection = .none
                        }
                        return
                    }
                    let request = fetchBuilder(searchText)
                    guard let reqCount = try? viewContext.count(for: request), reqCount > 0 else {
                        print("Not found")
                        selection = searchText.isEmpty ? .none : .plainText(searchText)
                        return
                    }
                    Task {
                        //FIXME: fix shows picker even if no recipes found
                        try await Task.sleep(for: .seconds(1))
//                        print("!!! ",inputText)
//                        print("!!! ", req)
                        
//                        {
                        guard let items = try? viewContext.fetch(request) else {
                            print("Failed to get autocompletion")
                            return
                        }
                        foundItems = .init(items: items)
//                        }
                    }
                })
                .onChange(of: selection){ _ in
                    foundItems = nil
                }
                .sheet(item: $foundItems) { items in
                    AutocomplePicker2(selection: $selection, itemTitle: itemTitle, items: items.items , inputText: inputText)

                    //if #available(iOS 16, *) {
                    //  .presentationCompactAdaptation(.none)
                    //} else {
                    .presentationDetents([.medium])
                    //}
                }
        }
        .onChange(of: selection) { selection in
            print("Selected: \(selection)")
            switch selection {
            case .none:
                inputText = ""
            case .plainText(let text):
                inputText = text
            case .item(let item):
                inputText = item[keyPath: itemTitle]
            }
        }.onAppear {
            print("Selected: \(selection)")
            switch selection {
            case .none:
                inputText = ""
            case .plainText(let text):
                inputText = text
            case .item(let item):
                inputText = item[keyPath: itemTitle]
            }
        }
        
    }
}

fileprivate extension AutocompleteView2 {
    struct FoundItems<T>: Identifiable {
        var id = UUID()
        var items: [T]
    }
}

fileprivate extension AutocompleteView2 {
    
    struct AutocomplePicker2<T>: View where T: NSFetchRequestResult, T: Hashable, T: Identifiable {
        @Binding var selection: AutocompleteSelection<T>
        var itemTitle: KeyPath<T,String>
        var items: [T]
        var inputText: String
        
        
        var body: some View {
            if items.count == 0 {
                Button {
                    selection = AutocompleteSelection.plainText(inputText)
                } label: {
                    Text( inputText)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                }
                .buttonStyle(.bordered)
                
                
            } else {
                ScrollView {
                    
                    LazyVStack {
                        ForEach(items) { item in
                            Button {
                                selection = AutocompleteSelection.item(item)
                            } label: {
                                Text(item[keyPath: itemTitle])
                                    .fixedSize(horizontal: true, vertical: false)
                                    .lineLimit(2)
                            }
                            .buttonStyle(.bordered)
                            
                        }
                    }
                    
                }
                .padding()
            }
            
        }
        
    }
}

#Preview {
    DinnerMenuDetail(dinnerMenu: DinnerMenu.firstForPreview())
}





struct AutocompleteView<T>: View where T: NSFetchRequestResult, T: Hashable, T: Identifiable {
    @Binding var selection : AutocompleteSelection<T>
    var itemTitle: KeyPath<T,String>
    var prompt = ""
    var fetchBuilder: (String) -> FetchRequest<T>
    @State private var inputText = ""
    @State private var isPickerShown2 = false
    @Environment(\.managedObjectContext) private var viewContext
    var isPickerShown: Bool {
        switch selection {
        case .none:
            return !inputText.isEmpty
        case .plainText(let string):
            return string != inputText
        case .item(let t):
            return t[keyPath: itemTitle] != inputText
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TextField("", text: $inputText, prompt: Text(prompt))

                .onChange(of: inputText, perform:  { searchText in
                    guard fetchBuilder(inputText).wrappedValue.count > 0 else {
                        print("Not found")
                        return
                    }
                    Task {
                        //FIXME: fix shows picker even if no recipes found
                        try await Task.sleep(for: .seconds(0.5))
//                        print("!!! ",inputText)
//                        print("!!! ", req)
                        
//                        {
                            isPickerShown2 = isPickerShown
//                        }
                    }
                })
                
                .popover(isPresented: $isPickerShown2) {
                    AutocomplePicker(inputText: inputText, selection: $selection, itemTitle: itemTitle, fetchBuilder: fetchBuilder)

                    //if #available(iOS 16, *) {
                    //  .presentationCompactAdaptation(.none)
                    //} else {
                    .presentationDetents([.medium])
                    //}
                }
        }
        .onChange(of: selection) { selection in
            print("Selected: \(selection)")
            switch selection {
            case .none:
                inputText = ""
            case .plainText(let text):
                inputText = text
            case .item(let item):
                inputText = item[keyPath: itemTitle]
            }
        }.onAppear {
            print("Selected: \(selection)")
            switch selection {
            case .none:
                inputText = ""
            case .plainText(let text):
                inputText = text
            case .item(let item):
                inputText = item[keyPath: itemTitle]
            }
        }
        
    }
}

fileprivate extension AutocompleteView {
    
    struct AutocomplePicker<T>: View where T: NSFetchRequestResult, T: Hashable, T: Identifiable {
        @Binding var selection: AutocompleteSelection<T>
        var itemTitle: KeyPath<T,String>
        @FetchRequest private var items: FetchedResults<T>
        private var inputText: String
        
        init(inputText: String, selection: Binding<AutocompleteSelection<T>>, itemTitle:KeyPath<T,String>, fetchBuilder: (String) -> FetchRequest<T>) {
            self.itemTitle = itemTitle
            self.inputText = inputText
            _selection = selection
            _items = fetchBuilder(inputText)
        }
        
        var body: some View {
            if items.count == 0 {
                Button {
                    selection = AutocompleteSelection.plainText(inputText)
                } label: {
                    Text( inputText)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                }
                .buttonStyle(.bordered)
                
                
            } else {
                ScrollView {
                    
                    LazyVStack {
                        ForEach(items) { item in
                            Button {
                                selection = AutocompleteSelection.item(item)
                            } label: {
                                Text(item[keyPath: itemTitle])
                                    .fixedSize(horizontal: true, vertical: false)
                                    .lineLimit(2)
                            }
                            .buttonStyle(.bordered)
                            
                        }
                    }
                    
                }
                .padding()
            }
            
        }
        
    }
}

// MARK: -
//FIXME: change predicate to search by title, descr, ingredients
struct RecipeAutocompletedField: View {
    @Binding var selection: AutocompleteSelection<Recipe>
    var prompt: String = "Start typing the recipe title"
    
    var body: some View {
        AutocompleteView2(selection: $selection, itemTitle: \.wrappedTitle, prompt: prompt   ) { text in
            let req = Recipe.fetchRequest()
            req.predicate = .init(format: "%K CONTAINS[cd] %@", #keyPath(Recipe.title), text)
            return req
        }
    }
}


