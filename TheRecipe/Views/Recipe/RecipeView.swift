//
//  RecipeView.swift
//  The Recipe
//
//FIXME: make test with fractions
//FIXME: make new recipe in RecipeListView after save or remove if not saved

import SwiftUI
import CoreData

struct RecipeView: View {
    @ObservedObject var recipe: Recipe
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.isPresented) private var isPresented
    
    @State private var editingIngredient: EditingIngredient?
    @State private var editingCookingStep: CookingStep?
    
    @State private var showShoppingListPicker = false
    @State private var showIngredientEditing = false
    @State private var showCookingStepEditing = false
    @State private var showAllCookingStepEditing = false
    @State private var showAllIngredientsEditing = false
    @State private var showTimeEditingSheet = false
    @State private var showTimeEditingSheet2 = false
    @State private var showStepByStepCooking = false
    @State private var showGallery = false
    @State private var showTagsPicker = false
    @State private var showChangeRatingPopover = false
    @State private var showRecipePreview = false
    
    @State private var newIngredient = ""
    @State private var newCookingStepDirection = ""
    @State private var cookingSteps = ""
    @State private var cookingIngredients = ""

//    let rowColor = Color(.white).opacity(0.25) //Color(.secondarySystemFill)//Color("BackgroundColor").opacity(0.25)
    //Drag-n-drop
//    @State private var droppedImages = [Image]()
//    @State private var imageUrl : Set<String> = Set()
//    @State private var imageLisenceUrl = ""
    var body: some View {
        List {
            //Photos, Summary & Title
            Section {
//                Text("Dropped images count \(droppedImages.count)")
//                    .listRowBackground( rowColor )
                // Summary
                VStack(alignment:.leading, spacing: 0) {
                    RecipeTextEditingView(entity: $recipe.wrappedSummary, placeholder: "Add Recipe Summary")
                        
                    Divider()
                    Text("Summary:", comment: "Summary TextEdit title")
                        .noteStyle()

                }
                //.listRowBackground( rowColor )
                
                //Source URL OR AUthor
                VStack(alignment:.leading, spacing: 0) {
                    RecipeTextEditingView(entity: $recipe.wrappedSource, placeholder: "Recipe Source")
                       Divider()
                    Text("Source:", comment: "Summary TextEdit title")
                        .noteStyle()

                }
                //Source URL OR AUthor
                VStack(alignment:.leading, spacing: 0) {
                    RecipeTextEditingView(entity: $recipe.wrappedVideoUrl, placeholder: "Recipe Video Url")
                       Divider()
                    Text("Video:", comment: "Video link TextEdit title")
                        .noteStyle()

                }
                //.listRowBackground( rowColor )
                HStack() {
                    // Cooking time
                    VStack(alignment:.leading, spacing: 0) {
                        
                        RecipeTimeEditAndView(time:$recipe.cookingTime,title: "Cooking time:", showTimeEditingSheet : $showTimeEditingSheet)
                        Divider()
                        Text("Cooking time:", comment: "Cooking time TextEdit title")
                            .noteStyle()
//                            .foregroundColor(.secondary)
                    }

                    Divider()
                    // Preparation time
                    VStack(alignment:.leading, spacing: 0) {
                       
                        RecipeTimeEditAndView(time:$recipe.preparationTime, title: "Preparation time:", showTimeEditingSheet : $showTimeEditingSheet2)
                        Divider()
                        Text("Preparation time:", comment: "Preparation time TextEdit title" )
                            .noteStyle()
                    }
    
                }
                //Put in how much this recipe makes
                VStack(alignment:.leading, spacing: 0) {
                    RecipeTextEditingView(entity: $recipe.wrappedMakes, placeholder: "How much Recipe makes. Ex. \"6 pancakes\" OR \"6 servings\" OR \"6 servings (approx. 2 cups per serving)\"")
                       Divider()
                    Text("Yield:", comment: "Makes TextEdit title")
                        .noteStyle()

                }
                //.listRowBackground( rowColor )
            } header: {
                RecipeHeaderView( recipe: recipe, showChangeRatingPopover: $showChangeRatingPopover)
            }
            .listSectionSeparator(.hidden)
            .listRowSeparator(.hidden)
            .headerProminence(.increased)
            //MARK: - Ingredients
            Section {
                ForEach(recipe.wrappedIngredients.ordered) { ingredient in
                    IngredientView(ingredient: ingredient)
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                recipe.wrappedIngredients.remove(ingredient)
                            }
                            Button("Edit") {
                                editingIngredient = .existing(ingredient)
                            }
                        }.onTapGesture {
                           editingIngredient = .existing(ingredient)
                        }
                    //.listRowBackground(rowColor)
                }
                .onMove(perform: recipe.wrappedIngredients.move(elementsAt:toPosition:))
                HStack {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.accentColor)

                    TextField("Add Ingredient 'amnt unit name'", text: $newIngredient)
                        .onSubmit {
//                            let step = recipe.addCookingStep()
//                            step.directions = newCookingStepDirection
//                            step.order = Int16(recipe.wrappedCookingSteps.count)
                            parseIngredients( newIngredient)
                            newIngredient = ""
                            
                        }
                }
                
                if recipe.wrappedIngredients.isEmpty {
                    Text("Add ingredients needed for your wonderful dish.")
                        .noteStyle()
                        .padding()
                }
                
            } header: {
                ingredientsHeader
            }
            //.listSectionSeparator(.hidden)
            .listRowSeparator(.hidden)
            
            //MARK: - Cooking Steps
            Section {
                ForEach(recipe.wrappedCookingSteps.ordered) { step in
                  //FIXME: on ipad doesnt fill form if edit step by swipe on first
                    CookingStepView(step: step)
                    
                        .swipeActions {
                            Button("Delete", role: .destructive) { recipe.wrappedCookingSteps.remove(step) }
                            Button("Edit") {
                                editingCookingStep = step
                                showCookingStepEditing = true
                            }
                            
                        }
                        //.listRowBackground( rowColor )
                }
                .onMove(perform: recipe.wrappedCookingSteps.move(elementsAt:toPosition:))
                HStack {
                    Text(Image(systemName: "\(recipe.wrappedCookingSteps.count+1).circle").renderingMode(.original))
                        .foregroundColor(.accentColor)
                    TextField("Add Step Direction", text: $newCookingStepDirection)
                        .onSubmit {
                            let step = recipe.addCookingStep()
                            step.directions = newCookingStepDirection
                            step.order = Int16(recipe.wrappedCookingSteps.count)
                            
                            newCookingStepDirection = ""
                            
                        }
                        
                }
                //.listRowBackground( rowColor )
                if recipe.wrappedCookingSteps.isEmpty {
                    Text("Add detailed steps with instructions for easy following by.")
                        .noteStyle()
                        .padding()
                        
                }
                
            } header: {
                cookingStepsHeader
            } footer: {
                Text("Double-tap for inline editing. Swipe left for more options.")
                    .noteStyle()
                    //.listRowBackground( rowColor )
            }
            .listRowSeparator(.hidden)
            
            //Comment to Recipe
            Section {
                VStack {
                    RecipeTextEditingView(entity: $recipe.wrappedComment, placeholder: "Add some notes here")
                        
//                    Divider()
//                    Text("Tap to comment this Recipe", comment: "Tap to comment this Recipe.")
//                        .noteStyle()
//                    TextEditor(text: $recipe.wrappedComment)
//                        .lineLimit(2...)
//                        .onSubmit {}
//                        .scrollContentBackground(.hidden)
//                        .background(rowColor)
//                        .listRowBackground( rowColor )
//                    Divider()
//                        .overlay(.primary)
                }
                //.listRowBackground(Color.clear)
                .scrollContentBackground(.hidden)
            } header: {
                commentHeader
            }
            footer: {
                Text("Double-tap for inline editing.")
                    .noteStyle()
            }
            //.listRowBackground(rowColor)
            .listSectionSeparator(.hidden)
            .listRowSeparator(.hidden)
            .headerProminence(.increased)
            
            // Tags
            Section {
                VStack {
                    TagsListView(provider: recipe)
                        .onTapGesture(perform: { showTagsPicker = true })
                        .listRowBackground( Color.clear )
                    TagsAutocompleterView( provider: recipe)
                }
            } header : {
                tagsHeader
            }
            
            .listSectionSeparator(.hidden)
            .listRowSeparator(.hidden)
//MARK: - Images section
            //FIXME: save images to recipe
            /*
            Section {
                
                ScrollView(.horizontal) {

                        HStack {
                            
                            ForEach(0..<droppedImages.count, id: \.self) { i in
                                droppedImages[i]
                                    .resizable()
                                    .scaledToFit()
//                                    .onLongPressGesture(perform: droppedImages.remove(droppedImages[i]))
//                                    .overlay(alignment: .center) {
//                                        Button("Delete") {
//                                            droppedImages.remove(droppedImages[i])
//                                        }
//                                    }
                            }
                            //FIXME: ImageWLicense in row
                            ForEach(0..<imageUrl.count, id: \.self) { i in
                                ImageWLicense(imageUrl: imageUrl[i])
//                                    .resizable()
//                                    .scaledToFit()
//                                    .onLongPressGesture(perform: droppedImages.remove(droppedImages[i]))
//                                    .overlay(alignment: .center) {
//                                        Button("Delete") {
//                                            droppedImages.remove(droppedImages[i])
//                                        }
//                                    }
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 300)//, maxHeight: .infinity)
                    
                }

                .dropDestination(for: Data.self) { items, location in
                    
                    guard let data = items.first else { return false}
                    if let url = URL(string: String(decoding: data, as: UTF8.self) )  {
                        //FIXME: make image from data
                        print("dropped image url")
                        $imageUrl.wrappedValue.insert(url.absoluteString)
                        return true
                    }
                    #if os(macOS)
                    if let uiimage = NSImage(data: data) {
                        print("dropped image")
                        let image = Image(kitImage: uiimage)
                        $droppedImages.wrappedValue.append(image)
                    }
                    #else
                    if let uiimage = UIImage(data: data) {
                        print("dropped image")
                        let image = Image(kitImage: uiimage)
                        $droppedImages.wrappedValue.append(image)
                    }
                    #endif

                    return true
                }

            }
            header: {
                Text("Images \(droppedImages.count)")+Text("Urls \(imageUrl.count)")
            }
             */
        }

#if !os(macOS)
        .listStyle(.grouped)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .scrollContentBackground(.hidden)
        .navigationTitle($recipe.wrappedTitle)
        .navigationDocument(recipe, preview: SharePreview(recipe.wrappedTitle, icon: Image(systemName: "list.bullet.rectangle")))
        .toolbarRole(.editor)
        .toolbar {
            toolbarItems
            ToolbarItem(placement: .automatic) {
                Button("Save", action: {
                    //FIXME: process add photos to the recipe
                    //Save recipe's changes
                    saveChanges()
                }).foregroundColor(.accentColor)
            }
        }
        .sheet(item: $editingCookingStep) {step in
            if let step = editingCookingStep {
                CookingStepEditView(step: step, recipe: recipe)
                    .onDisappear { editingCookingStep = nil;
                        showCookingStepEditing = false }
            }
        }

        .sheet(item: $editingIngredient) { ingredient in
           // if let ingredient = editingIngredient {
            ingredient.sheet(recipe: recipe, context: viewContext)
//                .onDisappear { editingIngredient = nil }
                .presentationDetents([.medium])
           // }
        }
        .sheet(isPresented: $showTagsPicker) {
            TagsEditView(provider: recipe)
        }
        .sheet(isPresented: $showAllCookingStepEditing) {
            EditInlineView(textForEdit: $cookingSteps)
                .onDisappear {
                    if !(cookingSteps.isEmpty) {
                        parseSteps()
                    }
                    cookingSteps = ""
                }
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showAllIngredientsEditing) {
            EditInlineView(textForEdit: $cookingIngredients, title: "Ingredients")
                .onDisappear {
                    if !(cookingIngredients.isEmpty) {
                        parseIngredients()
                    }
                    cookingIngredients = ""
                }
                .presentationDetents([.medium])
        }
        

        .sheet(isPresented: $showStepByStepCooking) {
            CookingView(recipe: recipe)
        }
        .sheet(isPresented: $showRecipePreview){
            RecipePreviewView(recipe: recipe)
        }
//        .onChange(of: editingIngredient) { _ in
//            showIngredientEditing = nil != editingIngredient
//        }
        .onChange(of: editingCookingStep) { _ in
            showCookingStepEditing =  !(newCookingStepDirection.isEmpty)
        }
        .onChange(of: isPresented) { isPresented in
            //FIXME: looks ugly and needs to be re-writed
            let isEditing = showCookingStepEditing || showIngredientEditing || showTagsPicker || showGallery || showChangeRatingPopover || showTimeEditingSheet || showTimeEditingSheet2 || showAllIngredientsEditing || showAllCookingStepEditing
            
            guard !isEditing else { return } //return if isEditing
//            guard !showCookingStepEditing, !showIngredientEditing, !showTagsPicker, !showGallery, !showChangeRatingPopover, !showTimeEditingSheet, !showTimeEditingSheet2, !showAllIngredientsEditing, !showAllCookingStepEditing  else { return }
            if isPresented {return} //this is new way onAppear
            if !(recipe.isEmpty) {
                //Save recipe's changes
                print("recipe in progress. save changes")
                saveChanges()
            }
            else if recipe.wrappedCookingSteps.count == 0, recipe.wrappedIngredients.count == 0, recipe.wrappedTitle.isEmpty  {
                //steps.count == 0 && ingredients.count == 0 means that recipe is empty.
                //So will not save it
                print("recipe is empty. delete")
                viewContext.delete(recipe)
            } else {
                print("recipe save anyway")
                saveChanges()
            }
        }
        .sheet(isPresented: $showGallery, onDismiss: {}) {
            PhotoGallery(source: recipe.wrappedImages)
        }
        .onDisappear {
            saveChanges()
        }
        
    }

    var toolbarItems: some ToolbarContent {
            ToolbarItem(placement: .automatic) {
                HStack {
                    if (recipe.ingredients?.count ?? 0 > 0 ||
                        recipe.cookingSteps?.count ?? 0 > 0) {
                        Menu("Cook It") {
                            Button {saveChanges();showStepByStepCooking = true} label:{
                                Label("Cook step-by-step", systemImage: "play.fill").foregroundColor(.accentColor)
                            }
                            Button {saveChanges();showRecipePreview = true} label:{
                                Label("On One page", systemImage: "list.clipboard").foregroundColor(.accentColor)
                            }
                            //Recipe's Gallery management
                            //FIXME: MAKE gallery functional again!
                            if recipe.images?.count ?? 0 > 0 && false {
                                Button {
                                    showGallery.toggle()
                                } label: {
                                    Label("Gallery", systemImage: "photo.artframe")
                                }
                            }
                            
                        }.foregroundColor(.accentColor)
                            .buttonStyle(.borderedProminent)
                        
                    }
                    
                }
            }
        }
    //MARK: - Headers
    
    private var ingredientsHeader: some View {
        LabeledContent {
            HStack {
                
                Button("Add Ingredient", systemImage: "plus") {
                    addIngredient()
                } 
                .labelStyle(.iconOnly)
                .buttonStyle(.bordered)
                if ((recipe.ingredients?.count ?? 0) == 0) {
                    Button("All Ingredients", systemImage: "list.number") {
                        editAllIngredients()
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.bordered)
                }
                //FIXME: Get back shopping list
                if false {
                    Button("Add ingredients to a shopping list", systemImage: "cart.badge.plus") {
                        showShoppingListPicker = true
                    }
                    .buttonStyle(.bordered)
                    .labelStyle(.iconOnly)
                    .confirmationDialog("Pick List", isPresented: $showShoppingListPicker) {
                        Button("OK") {}
                    }
                }
            }
            .foregroundColor(.accentColor)
        } label: {
            Text("Ingredients (\(recipe.ingredients?.count ?? 0))")
                .sectionHeaderStyle()
        }
        
    }
    
    
    
    private var cookingStepsHeader: some View {
        LabeledContent {
            Button("All Steps", systemImage: "list.number"){
                editAllSteps()
                   
            }.foregroundColor(.accentColor)
                .labelStyle(.iconOnly)
                .hidden(when: recipe.cookingSteps?.count ?? 0 > 0)
        } label: {
            Text("Directions (\(recipe.wrappedCookingSteps.count))")
                .sectionHeaderStyle()
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
    private var commentHeader: some View {
        LabeledContent {
            
        } label: {
            Text("Notes")
                .sectionHeaderStyle()
        }
    }
    //MARK: - Showing sheets
    private func addIngredient() {
        editingIngredient = .newOne //recipe.addIngredient()
    }
    
    private func addCookingStep() {
        editingCookingStep = recipe.addCookingStep()
    }
    
    private func editAllSteps() {
        showAllCookingStepEditing = true
    }
    private func editAllIngredients() {
        showAllIngredientsEditing = true
    }
    //MARK: -  Parsing
    private func parseSteps() {
        
        let llines = cookingSteps.lines
        for (index, line) in llines.enumerated() {
            let step = recipe.addCookingStep()
            step.directions = line
            step.order = Int16(index)

        }
    }
    private func parseIngredients() {
        parseIngredients(cookingIngredients)
    }
    private func parseIngredients(_ ingredientStr : String) {
        let llines = ingredientStr.lines
        for line in llines {
            let sentence = line.trimmingCharacters(in: .whitespacesAndNewlines)// String(text[tokenRange])
            
            let splits = sentence.split(separator: " ", maxSplits:2, omittingEmptySubsequences: true)
            //this is ugly but breaks works like return
            if splits.count == 1  {
                //Name only ingredient
                let ing: Ingredient = Ingredient.findOrNew(String(splits[0]), by: \.name, inContext: viewContext)
                
                let _ = recipe.addIngredient(ing, amount: 0, unit: nil)
                
            } else {
                //var hasAmountWSpacing = false
                var ingredientamount = 0.0
                //This is the case than ingredientAmount is written like "1 1/2"
//                let num1 = String(splits[0]).numberWFractionsToDouble()
//                let num2 = String(splits[1]).numberWFractionsToDouble()
//                if  num1 > 0 && num2 > 0 {
//                    hasAmountWSpacing = true
//                    ingredientamount = num1+num2
//                } else {
                    //This is the case than ingredientAmount is written like "1/2" or "0.5"
                    let amount = String(splits[0]) //Double
                    ingredientamount = amount.numberWFractionsToDouble()
//                }
                
                let measureUnit = String(splits[1]).lowercased()
                let ingredientwrappedUnit = measureUnit.getUnit().unit
                
                let koeff = measureUnit.getUnit().koeff
                
                var name = ""
                if ingredientwrappedUnit == nil, splits.count == 2 {
                    name = measureUnit
                } else {
                    name = String(splits[2])
                }
                var comment : String?
                if name.contains("(") {
                    let startComment = name.firstIndex(of: "(")!
                    let endComment = name.firstIndex(of: ")")!
                    comment = String(name[startComment..<endComment].dropFirst())
                    name.removeSubrange(startComment...endComment)
                    name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                let ing: Ingredient = Ingredient.findOrNew(name, by: \.name, inContext: viewContext)
                
                let ingredient = recipe.addIngredient(ing, amount: ingredientamount*koeff, unit: ingredientwrappedUnit)
                ingredient.comment = comment
            }
        }
    }
    
    private func saveChanges() {
        let tagRecipe = Tag.findOrNew("recipe", by: \.name, inContext: viewContext)
        
        if !(recipe.wrappedTags.contains(tagRecipe)) {
            recipe.addToTags(tagRecipe)
        }
        if (recipe.wrappedVideoUrl.isEmpty) {
            recipe.videoUrl = ""
        } 
        if recipe.hasChanges || recipe.hasPersistentChangedValues {
            print("Recipe saved changes")
            viewContext.saveChanges()
        } else {
            print("Nothing changed in Recipe. Skip save changes")
        }
    }
    
    // MARK: -
    private enum EditingIngredient: Identifiable {
        var id: String {
            if case let .existing(ingredient) = self {
                return ingredient.objectID.uriRepresentation().absoluteString
            }
            return "newRecipeIngredient"
        }
        
//        var recipeIngredient: RecipeIngredient? {
//            if case let .existing(ingredient) = self {
//                return ingredient
//            }
//            return nil
//        }
        func sheet(recipe: Recipe, context: NSManagedObjectContext)-> IngredientEditView {
            switch self {
            case let .existing(ingredient):
                return IngredientEditView(recipeIngredient: ingredient, useContext: context)
            case .newOne:
                return IngredientEditView(newOneIn: recipe, useContext: context)
            }
        }
        
        case newOne, existing(RecipeIngredient)
    }
}


// MARK: - Previews
#Preview {

    RecipeView(recipe: Recipe.firstForPreview())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .background( Image("bg-pattern")
            .resizable(resizingMode:.tile)
            .aspectRatio( contentMode: .fill)
            .opacity(0.1)
            .ignoresSafeArea())

}
