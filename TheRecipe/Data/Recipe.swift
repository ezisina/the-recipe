//
//  Recipe.swift
//  TheRecipe
//

import CoreData
import UniformTypeIdentifiers

extension UTType {
    static var recipe: UTType {
        UTType(exportedAs: "therecipe.recipe.type")
    }
}
/// Recipe entity.
///
/// Contains all the information about a recipe.
class Recipe: NSManagedObject, Codable, Referenceable, ReferenceContainer {
    /// List of references to Tag
    private var tagReferences: [Reference] = []
    
    var reference: Reference {
        .init(key: "uuid", value: uuid ?? "")
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
              throw ImportExportError.managedObjectContextRequired
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(String.self, forKey: .uuid)
        title = try container.decode(String.self, forKey: .title)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        rating = try container.decode(Int16.self, forKey: .rating)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        videoUrl = try container.decodeIfPresent(String.self, forKey: .videoUrl)
        cookingTime = try container.decode(Double.self, forKey: .cookingTime)
        lastModified = try container.decode(Date.self, forKey: .lastModified)
        preparationTime = try container.decode(Double.self, forKey: .preparationTime)
        servings = try container.decode(Int16.self, forKey: .servings)
        ingredients = try container.decodeIfPresent(Set<RecipeIngredient>.self, forKey: .ingredients) as NSSet?
        cookingSteps = try container.decode(Set<CookingStep>.self, forKey: .cookingSteps) as NSSet
        images = try container.decodeIfPresent(Set<RecipeImage>.self, forKey: .images) as NSSet?
        tagReferences = try container.decodeIfPresent([Reference].self, forKey: .tags) ?? []
        parts = try container.decodeIfPresent(Set<Recipe>.self, forKey: .parts) as NSSet?
        makes = try container.decode(String.self, forKey: .makes)
        remarks = try? container.decode( RecipeRemarks.self, forKey: .remarks)
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(cookingTime, forKey: .cookingTime)
        try container.encode(lastModified, forKey: .lastModified)
        try container.encode(preparationTime, forKey: .preparationTime)
        try container.encode(servings, forKey: .servings)
        try container.encode(makes, forKey: .makes)
        if let summary = summary {
            try container.encode(summary, forKey: .summary)
        }
        if let comment = comment {
            try container.encode(comment, forKey: .comment)
        }
        try container.encode(rating, forKey: .rating)
        if let source = source {
            try container.encode(source, forKey: .source)
        }
        if let videoUrl = videoUrl {
            try container.encode(videoUrl, forKey: .videoUrl)
        }
        try container.encode(title, forKey: .title)
        try container.encode(cookingSteps as? Set<CookingStep> ?? [], forKey: .cookingSteps)
        try container.encode(images as? Set<RecipeImage> ?? [], forKey: .images)
        if !wrappedIngredients.isEmpty {
            try container.encode(wrappedIngredients, forKey: .ingredients)
        }
        if !wrappedTags.isEmpty {
            try container.encode(wrappedTags.map { $0.reference }, forKey: .tags)
        }
        if !wrappedParts.isEmpty {
            try container.encode(wrappedParts, forKey: .parts)
        }
        try container.encode(remarks, forKey: .remarks)
    }
    
    func resolveReferences() {
        guard let context = managedObjectContext else {
            return
        }
        
        wrappedTags = .init(tagReferences.compactMap { $0.resolve(Tag.self, inContext: context) })
        wrappedIngredients.forEach { $0.resolveReferences() }
        wrappedCookingSteps.forEach { $0.resolveReferences() }
    }
}

// MARK: - Coding keys

extension Recipe {
    enum CodingKeys: CodingKey {
        case uuid, cookingTime, lastModified, preparationTime, servings, summary, comment, rating, title, cookingSteps, images, ingredients, tags, source, dinnerMenuItems, parts, makes, videoUrl, remarks
    }
}


