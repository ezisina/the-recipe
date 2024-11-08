//
//  IngredientView.swift
//  TheRecipe
//

import SwiftUI


struct IngredientView: View {
    @ObservedObject var ingredient: RecipeIngredient
    
    var body: some View {
        VStack(alignment:.leading, spacing: 0) {
            HStack {
                if (ingredient.amount > 0) {
                    Text(ingredient.amount, format: .number)
                    + Text(" \(ingredient.unit ?? "") ")
                    + Text(ingredient.ingredientName)
                        .fontWeight(.bold)
                } else {
                    Text(ingredient.ingredientName)
                        .fontWeight(.bold)
                }
                
            }
            if (!(ingredient.comment ?? "").isEmpty) {
                Text(ingredient.comment ?? "")
                    .font(.callout)
                    .italic()
            }
        }
    }
}


// MARK: - Previews

struct IngredientView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientView(ingredient: RecipeIngredient.firstForPreview())
    }
}
