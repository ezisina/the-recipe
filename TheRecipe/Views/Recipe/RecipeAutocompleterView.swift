//
//  RecipeAutocompleterView.swift
//  TheRecipe
//
//  Created by Elena Zisina on 8/31/23.
//

import SwiftUI
import CoreData

//struct RecipeAutocompleterView: View  {
//    @State private var recipeText : String  = ""
//    @State private var popupRecipePresented : Bool =  false
////    @ObservedObject var provider: Provider
//    @Binding var selection : AutocompleteSelection<T>
//    @FetchRequest(sortDescriptors: [ SortDescriptor(\Recipe.name, order: .forward) ], predicate: NSPredicate(value: true), animation: .default)
//    private var recipes: FetchedResults<Recipe>
//
//    @Environment(\.managedObjectContext) private var viewContext
//
//    var body: some View {
//
//        VStack(spacing: 0) {
//            TextField("+Tags", text: $recipeText)
//                .onChange(of: recipeText, perform: { newVal in
//                    //Delay tag filter to trigger better combination
//                    Task { @MainActor in
//
//                        try await Task.sleep(for: .seconds(0.5))
//
//                        if !(newVal.isEmpty) {
//                            popupRecipePresented = true
//                        }
//                        //TODO: add predicate to filter recipes
////                        let filteredMatches = recipes.filter{$0.wrappedName.contains(tagText)}
////                            .filter{!(provider.wrappedTags.contains($0))}
////                        if filteredMatches.isEmpty {
////                            popupRecipePresented = false
////                        }
//                    }
//                })
//                .onSubmit {
//                    //TODO: select recipe or new title
//                    processRecipe()
//                }
//                .popover(isPresented: $popupRecipePresented) {
//                    VStack {
//
//                        HStack {
//                            Text("Found tags...")
//                            Spacer()
//                        }
//                        .sheetTitleStyle()
//                        .padding(.bottom, 15)
//
//                        ScrollView {
//                            LazyVStack{
//                                ForEach(recipes) { recipe in
//                                    Button {
//
//                                    } label: {
//                                        Text(recipe.wrappedTitle)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//
//        }
//    }
//
//    func processSelection() {}
//
//    func filterRecipes() {}
//}
//
//struct RecipeAutocompleterView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipeAutocompleterView()
//    }
//}
//
//enum AutocompleteSelection<T>: Hashable, Equatable where T: Hashable, T: Equatable {
//    case none
//    case plainText(String)
//    case item(T)
//}
