//
//  RecipeDetailView.swift
//  The Recipe
//

import SwiftUI

struct DetailView: View {

    @EnvironmentObject private var appState:AppState
    var body: some View {
        VStack {
            if appState.selectedFeature == .recipe {
                if let recipe = appState.selectedRecipe {
                    if recipe.isInProgress {//!(recipe.wrappedIngredients.count > 0 || recipe.wrappedCookingSteps.count > 0) {
                        RecipeView(recipe: recipe)
                    } else {
                        RecipePreviewView(recipe: recipe)
                        
                    }
                } else {
                    chooseNothingView
                }
            } else if appState.selectedFeature == .dinnerMenu {
                if let dinnerMenu = appState.selectedDinnerMenu {
                    
                    DinnerMenuDetail(dinnerMenu: dinnerMenu)
                } else {
                    chooseNothingView
                }
            } else {
                chooseNothingView
            }
            
            
        }
    }
    
    var chooseNothingView : some View {
        Group {
            if #available(iOS 17.0, *) {
                ContentUnavailableView {
                    Label("Recipe here".localizedUppercase, systemImage: "hand.point.left.fill")
                } description: {
                    Text("Choose or create a new one".localizedUppercase)
                }
            } else {
                Label("Choose or create a new recipe".localizedUppercase, systemImage: "hand.point.left.fill")
                    //.frame(maxWidth:.infinity, maxHeight: .infinity)
                    .font(.callout)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


// MARK: - Previews

#Preview {
    DetailView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AppState())
}
