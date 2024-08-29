//
//  Bundle+Extension.swift
//  TheRecipe
//
//  Created by Elena Zisina on 6/13/23.
//

import Foundation

extension Bundle {
    func decode<T: Decodable>(_ file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print(error)
            fatalError("Failed to decode \(file) from bundle.")
        }

    }
    
    func save(_ file : String, json : Data) -> Bool {

        var isSuccess = false
        
        guard let url = self.url(forResource: file, withExtension: nil) else {
           return isSuccess
        }
        
        do {
            try json.write(to: url)
            isSuccess = true
        } catch {
            print(error.localizedDescription)
        }
        return isSuccess
    }
}
