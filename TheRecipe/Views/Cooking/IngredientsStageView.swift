//
//  IngredientsStageView.swift
//  TheRecipe
//
//  Created by Elena Zisina on 7/21/22.
//

import SwiftUI

struct IngredientsStageView: View {
    var recipe : Recipe
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            if (!recipe.wrappedSummary.isEmpty) {
                      
               Text(recipe.summary ?? "Summary simjdjdj sjsjs роіц цоwdwj \n j dhcs hshkd  dckdkc jds ashshjdchsjdhc hce hvkdhvk hdkvhfdkvh kdhvkds vvfdhdkfhv vdhfkv dkfhvdkfvh dkfjhvdkfvh dfhvdu fddf dfjhdfj")
                .foregroundColor(.secondary)
                .font(.subheadline)
                .padding()
                          
            }
            Text("Ingredients:")
                .sectionHeaderStyle()
                .font(.title)
            ScrollView {
                
                VStack(alignment: .center){
                    ForEach(recipe.wrappedIngredients.ordered) {item in
                        IngredientView(ingredient: item)
                            .font(.title2)
                    }
                }
            }
           
        }.padding()
    }
}

struct IngredientsStageView_Previews: PreviewProvider {
    private static let context = PersistenceController.preview.container.viewContext
    private static var recipe: Recipe {
        let req = Recipe.fetchRequest()
        return (try? context.fetch(req).first) ?? Recipe(context: context)
    }
    static var previews: some View {
        IngredientsStageView(recipe: recipe)
            .environment(\.managedObjectContext, context)
    }

}
