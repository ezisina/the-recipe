//
//  DinnerItem+Extensions.swift
//  TheRecipe
//
//  Created by Elena Zisina on 7/4/23.
//

import Foundation
extension DinnerMenuItem: EasyFindable {
    /// Non-optional ``title`` with an empty string as a default value.
    var wrappedName: String {
        title ?? ""
    }
    /// Non-optional ``summary`` with an empty string as a default value.
    var wrappedSummary: String {
        summary ?? ""
    }
    
    /// Wrapped ``order`` represented as Int for easier operations.
    var wrappedOrder: Int {
        get { Int(order) }
        set { order = Int16(newValue) }
    }
    
    
}
