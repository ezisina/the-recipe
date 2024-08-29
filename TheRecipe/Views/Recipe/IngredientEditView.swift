//
//  IngredientEditView.swift
//  TheRecipe
//

import SwiftUI
import CoreData

struct IngredientEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var vm: ViewModel
    
    @FetchRequest(sortDescriptors: [ .init(keyPath: \Ingredient.name, ascending: true) ], predicate: .init(value: false))
    private var matchingIngredients: FetchedResults<Ingredient>
    
    let rowColor = Color(.secondarySystemFill)
    
    init(recipeIngredient: RecipeIngredient, useContext context: NSManagedObjectContext) {
        _vm = StateObject(wrappedValue: ViewModel(recipe: recipeIngredient.recipe, recipeIngredient: recipeIngredient, context: context))
    }
    init(newOneIn recipe: Recipe, useContext context: NSManagedObjectContext) {
        _vm = StateObject(wrappedValue: ViewModel(recipe: recipe, recipeIngredient: nil, context: context))
    }
    
    var body: some View {
        EditingSheet("Ingredient", editing: vm.recipeIngredient) {
            Form {
                MySection {
                    TextField("Type in the ingredient", text: $vm.ingredientName)
                        .onChange(of: vm.ingredientName, perform: autocompleteIngredients)
                        .onChange(of: vm.pickedIngredient, perform: selectIngredient)
                        .listRowBackground( rowColor )
                    Picker("Ingredient", selection: $vm.pickedIngredient) {
                        ForEach(matchingIngredients) { ingredient in
                            Text(ingredient.wrappedName)
                                .tag(Selection<Ingredient>.one(ingredient))
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                    .offset(x: 16)
                    .listRowBackground( rowColor )
                    TextField("Comment (optional)", text: $vm.comment)
                        .onChange(of: vm.comment) { comment in
                            vm.recipeIngredient.comment = comment.isEmpty ? nil : comment
                        }
                        .listRowBackground( rowColor )

                    LabeledContent {
                        Picker("Units", selection: $vm.pickedUnit) {
                            ForEach(Units.list) { unit in
                                Text(unit.symbol)
                                    .tag(unit)
                            }
                        }
                        .labelsHidden()
                        .onChange(of: vm.pickedUnit) { unit in
                            vm.recipeIngredient.wrappedUnit = unit
                        }
                    } label: {
                        TextField("Amount", text: $vm.amount)
//                            .keyboardType(.numbersAndPunctuation)
                            .onChange(of: vm.amount) { amnt in
                                vm.recipeIngredient.amount = Double(amnt) ?? 0
                            }
                    }
                    .listRowBackground( rowColor )
                }
            }
            .scrollContentBackground(.hidden)
            
        } validate: {
            vm.validateForm()
        } onSave: {
            print("save ingredient")
            vm.saveChanges()
        } onCancel: {
            print("cancel ingredient")
        }
    }
    
    private func autocompleteIngredients(_ searchString: String) {
        switch vm.pickedIngredient {
        case let .one(selectedIngredient) where selectedIngredient.wrappedName == vm.ingredientName:
            // This case prevents interfering with ingredient selection - when the selected object actually matches the
            // input string. In this case the predicate is reset and it should stay this way.
            return
        default:
            break
        }
        vm.pickedIngredient = .none
        matchingIngredients.nsPredicate = .init(format: "%K contains[cd] %@", #keyPath(Ingredient.name), vm.ingredientName)
    }
    
    private func selectIngredient(_ selection: Selection<Ingredient>) {
        if case let .one(ingredient) = selection {
            vm.setIngredient(ingredient)
            matchingIngredients.nsPredicate = .init(value: false)
        }
    }
    


}

extension IngredientEditView {
    fileprivate class ViewModel: ObservableObject {
        let context: NSManagedObjectContext
        let recipeIngredient: RecipeIngredient
        let recipe: Recipe?
        
        @Published var ingredientName = ""
        @Published var amount = ""
        @Published var pickedIngredient: Selection<Ingredient> = .none
        @Published var pickedUnit: Unit = Units.list.first!
        @Published var comment = ""

        
        init(recipe:Recipe?, recipeIngredient: RecipeIngredient? = nil, context parentContext: NSManagedObjectContext) {
            context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.parent = parentContext
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            context.undoManager = nil
            context.name = "EditIngredientContext"
            
            if let recipe = recipe {
                self.recipe = context.object(with: recipe.objectID) as? Recipe
            } else {
                self.recipe = nil
            }
            
            if let ingredient = recipeIngredient, let ingredientObj = context.object(with: ingredient.objectID) as? RecipeIngredient {
                self.recipeIngredient = ingredientObj
            } else {
                self.recipeIngredient = recipe?.addIngredient() ?? RecipeIngredient(context: context)
            }
            
            if let existingIngredient = self.recipeIngredient.ingredient {
                pickedIngredient = .one(existingIngredient)
                ingredientName = existingIngredient.wrappedName
            }
            amount = "\(self.recipeIngredient.amount)"
            if let unit = self.recipeIngredient.wrappedUnit {
                pickedUnit = unit
            } else {
                self.recipeIngredient.wrappedUnit = pickedUnit
            }
            comment = self.recipeIngredient.comment ?? ""
        }
        
        func setIngredient(_ ingredient: Ingredient) {
            guard let ingredient = context.object(with: ingredient.objectID) as? Ingredient else {
                return
            }
            ingredientName = ingredient.wrappedName
            recipeIngredient.ingredient = ingredient
        }
        
        func saveChanges() {
            let ingredient: Ingredient
            if case let .one(selectedIngredient) = pickedIngredient, let selectedIngredient = context.object(with: selectedIngredient.objectID) as? Ingredient {
                ingredient = selectedIngredient
            } else {
                ingredient = Ingredient(context: context)
                ingredient.name = ingredientName
                recipe?.addToIngredients(recipeIngredient)
            }
            recipeIngredient.ingredient = ingredient
            context.saveChanges()
        }
        
        func validateForm() -> Bool {
            guard !ingredientName.isEmpty else {
                return false
            }
            guard let amnt = Double(amount), amnt > 0 else {
    //            some ingredients might be without amount. Salt in salad on example
                return true
            }
            return true
        }
        
    }
}




struct IngredientEditView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
    
    struct Preview: View {
        @Environment(\.managedObjectContext) private var viewContext
        var body: some View {
            IngredientEditView(recipeIngredient: RecipeIngredient.firstForPreview(), useContext: viewContext)
        }
    }
}
