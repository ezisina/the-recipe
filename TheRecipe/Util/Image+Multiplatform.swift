//
//  Image+Multiplatform.swift
//  TheRecipe
//

import SwiftUI

#if os(macOS)
    import Cocoa
    typealias KitImage = NSImage
#else
    import UIKit
    typealias KitImage = UIImage
#endif

extension Image {
    #if os(macOS)
        init(kitImage: NSImage) {
            self.init(nsImage: kitImage)
        }
    #else
        init(kitImage: UIImage) {
            self.init(uiImage: kitImage)
        }
    #endif
}

#if os(macOS)
extension NSImage {
    convenience init?(systemName:String) {
        self.init(systemSymbolName: systemName, accessibilityDescription: nil)
    }
    
    func pngData() -> Data? {
        tiffRepresentation?.bitmap?.png
    }
    
    
}

extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}

#endif
