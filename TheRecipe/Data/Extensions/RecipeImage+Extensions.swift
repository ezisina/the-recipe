//
//  RecipeImage+Extensions.swift
//  TheRecipe
//

import CoreData

extension RecipeImage {
    /// The unpacked image, ready to use.
    var kitImage: KitImage? {
        guard let data = image, let kImg = KitImage(data: data) else {
            return nil
        }
        return kImg
    }
}
