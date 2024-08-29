//
//  RecipeHeaderViewModel.swift
//  TheRecipe
//

import Foundation
import Combine
import SwiftUI
import PhotosUI

extension RecipeHeaderView {
    
    /// ViewModel for ``RecipeHeaderView``.
    ///
    /// Provides image gallery handling, including pre-caching the images as ``KitImage`` to allow for direct display.
    @MainActor
    class ViewModel: ObservableObject {
        /// The recipe watched by the model.
        @Published var recipe: Recipe
        /// Recipe images, suitable for gallery presentation.
        @Published var images: [KitImage] = []
        /// The subscription that monitors ``recipe`` changes and updates the gallery if needed.
        private var recipeChangeSubscription: AnyCancellable?
        
        /// Initializes the view model with the given recipe.
        ///
        /// - Parameter recipe: Recipe to work with.
        init(recipe: Recipe) {
            self.recipe = recipe
            recipeChangeSubscription = recipe.objectWillChange
                .receive(on: RunLoop.main)
                .sink { [weak self] in
                    self?.updateImages()
                }
            
            updateImages()
        }
        
        /// Adds a picked photo to the recipe's gallery.
        ///
        /// - Parameter newPhoto: New photo picked by the user.
        func addPhoto(_ newPhoto: PhotosPickerItem?) {
            guard let newPhoto = newPhoto else {
                return
            }
            Task { [weak self] in
                guard let context = recipe.managedObjectContext, let data = try? await newPhoto.loadTransferable(type: Data.self) else {
                    return
                }
                await context.perform {
                    let image = RecipeImage(context: context)
                    image.image = data
                    self?.recipe.addToImages(image)
                    context.saveChanges()
                }
            }
        }
        
        /// Updates the gallery from the Core Data storage.
        ///
        /// Unpacks all the pictures from their binary representation and stores them in ``images`` array in the proper order.
        private func updateImages() {
            images = recipe.wrappedImages.ordered.compactMap {
                guard let imageData = $0.image, let kitImage = KitImage(data: imageData) else {
                    return nil
                }
                return kitImage
            }
            if images.isEmpty {
                images = [KitImage(systemName: "photo")!]
            }
        }
    }
}
