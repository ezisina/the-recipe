//
//  TagProvider.swift
//  TheRecipe
//
//  Created by Elena Zisina on 8/9/23.
//

import Foundation


protocol TagProvider {
    var wrappedTags: Set<Tag> { get }
    
    func removeFromTags(_ value: Tag)
    
    func addToTags(_ value: Tag)
}
