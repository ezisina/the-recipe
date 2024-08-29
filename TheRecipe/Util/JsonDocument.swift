//
//  JsonDocument.swift
//  TheRecipe
//
//  Created by Elena Zisina on 10/5/23.
//

import SwiftUI
import UniformTypeIdentifiers
import CoreData


struct JsonDocument: FileDocument {
    // tell the system we support only json
    static var readableContentTypes = [UTType.json]

    private var data: Data

    init(data: Data) {
        self.data = data
    }

    // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw Error.invalidDocument
        }
        self.data = data
    }

    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        .init(regularFileWithContents: data)
    }

    enum Error: Swift.Error {
        case invalidDocument
    }
}
