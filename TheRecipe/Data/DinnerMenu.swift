//
//  Dinner.swift
//  TheRecipe
//
//  Created by Elena Zisina on 7/2/23.
//

import CoreData

class DinnerMenu: NSManagedObject, Codable, ReferenceContainer {
    /// List of references to Tag
    private var tagReferences: [Reference] = []
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
              throw ImportExportError.managedObjectContextRequired
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        source = try container.decode(String.self, forKey: .source)
        descr = try container.decodeIfPresent(String.self, forKey: .descr)
        tagReferences = try container.decodeIfPresent([Reference].self, forKey: .tags) ?? []
        dinnerMenuItems = try container.decodeIfPresent(Set<DinnerMenuItem>.self, forKey: .dinnerMenuItems) as NSSet?
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(source, forKey: .source)
        try container.encode(descr, forKey: .descr)

        if !wrappedDinnerMenuItems.isEmpty {
            try container.encode(wrappedDinnerMenuItems, forKey: .dinnerMenuItems)
        }
        
        if !wrappedTags.isEmpty {
            try container.encode(wrappedTags.map { $0.reference }, forKey: .tags)
        }
    }
    
    func resolveReferences() {
        guard let context = managedObjectContext else {
            return
        }
        wrappedTags = .init(tagReferences.compactMap { $0.resolve(Tag.self, inContext: context) })
        wrappedDinnerMenuItems.forEach { $0.resolveReferences() }
    }
}

// MARK: - Coding keys

extension DinnerMenu {
    enum CodingKeys: CodingKey {
        case title, descr, tags, dinnerMenuItems, source
    }
}
