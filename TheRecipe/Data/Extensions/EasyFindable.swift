//
//  EasyFindable.swift
//  TheRecipe
//
//  Created by Elena Zisina on 6/13/23.
//

import CoreData


protocol EasyFindable {}

extension EasyFindable where Self: NSManagedObject {
    static func findOrNew<T>(_ value: T, by key: ReferenceWritableKeyPath<Self, T>, inContext context: NSManagedObjectContext) -> Self {
        findOrNew(value, by: key, inContext: context) { context in
            let obj = Self(context: context)
            obj[keyPath: key] = value
            return obj
        }
    }
    
    static func findOrNew<T>(_ value: T, by key: ReferenceWritableKeyPath<Self, T>, inContext context: NSManagedObjectContext, newItemBuilder: @escaping (NSManagedObjectContext) -> Self) -> Self {
        let fetch = NSFetchRequest<Self>(entityName: Self.entity().name ?? "")
        let keyExpr = NSExpression(forKeyPath: key)
        let valExpr = NSExpression(forConstantValue: value)
        fetch.predicate = NSComparisonPredicate(leftExpression: keyExpr, rightExpression: valExpr, modifier: .direct, type: .equalTo, options: .caseInsensitive)
        
        if let frst = try? context.fetch(fetch), let val = frst.first   {
            return val
        }
        return newItemBuilder(context)
    }
}
