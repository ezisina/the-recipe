//
//  Recipe+Transferrable.swift
//  The Recipe
//

import CoreTransferable

extension Recipe: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { recipe in
            [
                recipe.wrappedTitle,
                recipe.summary
            ]
                .compactMap { $0 }
                .joined(separator: "\n\n")

        }
    }
}
