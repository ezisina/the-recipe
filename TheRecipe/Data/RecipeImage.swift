//
//  RecipeImage.swift
//  TheRecipe
//

import CoreData

/// Image entity.
///
/// Represents an image attached to the recipe.
class RecipeImage: NSManagedObject, Codable, Ordered {

    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
              throw ImportExportError.managedObjectContextRequired
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        image = try container.decodeIfPresent(Data.self, forKey: .image)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        licenseUrl = try container.decodeIfPresent(String.self, forKey: .licenseUrl)
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(image, forKey: .image)
        if !(imageUrl?.isEmpty ?? true) {
            try container.encode(imageUrl, forKey: .imageUrl)
        }
        if !(licenseUrl?.isEmpty ?? true) {
            try container.encode(licenseUrl, forKey: .licenseUrl)
        }
    }
}


// MARK: - Coding keys

extension RecipeImage {
    enum CodingKeys: CodingKey {
        case image
        case imageUrl
        case licenseUrl
    }
}
