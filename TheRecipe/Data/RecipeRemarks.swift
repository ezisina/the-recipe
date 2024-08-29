//
//  RecipeRemarks.swift
//  TheRecipe
//
//  Created by Elena Zisina on 7/11/24.
//

import Foundation
import CoreData

class RecipeRemarks: NSManagedObject, Codable {
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw ImportExportError.managedObjectContextRequired
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        rating = try container.decodeIfPresent(Int16.self, forKey: .rating) ?? 3
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(comment, forKey: .comment)
        try container.encodeIfPresent(rating, forKey: .rating)
    }
}
// MARK: - Coding keys

extension RecipeRemarks {
    enum CodingKeys: CodingKey {
        case comment
        case rating
    }
}
