//
//  AdaptiveLayoutView.swift
//  TheRecipe
//
//  Created by Elena Zisina on 10/12/23.
//

import SwiftUI

struct AdaptiveLayout<Content> : View where Content : View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var horizontalOn : Set<UserInterfaceSizeClass> = [.regular]
    var hAlignment : HorizontalAlignment = .center
    var vAlignment : VerticalAlignment = .center
    var spacing : Spacing?
    
    
    private var hSpacing : CGFloat? {
        guard let spacing = spacing else {
            return nil
        }
        switch spacing {
            
        case let .single(value):
            return value
        case let .separate(horizontal:  value, _ ):
            return value
        }
        
    }
    private var vSpacing : CGFloat? {
        guard let spacing = spacing else {
            return nil
        }
        switch spacing {
            
        case let .single(value):
            return value
        case let .separate(_, vertical:  value):
            return value
        }
    }
    
    @ViewBuilder var content : Content
    
    var body: some View {
        if horizontalOn.contains(horizontalSizeClass ?? .regular) {
            HStack(alignment: vAlignment, spacing: hSpacing) {
                content
            }
        } else {
            VStack(alignment: hAlignment, spacing: vSpacing) {
                content
            }
        }
    }
    
    enum Spacing {
        case single(CGFloat)
        case separate(horizontal: CGFloat, vertical: CGFloat)
    }
}

struct AdaptivePaddingModifier : ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var sizeClasses: Set<UserInterfaceSizeClass>
    var edges: Edge.Set
    var length: CGFloat?
    
    func body(content: Content) -> some View {
        if (sizeClasses.contains(horizontalSizeClass ?? .regular)) {
            content
                .padding(edges, length)
        } else {
            content
        }
    }
}

extension View {
    func padding(when size: UserInterfaceSizeClass, _ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        self.modifier(AdaptivePaddingModifier(sizeClasses: [size], edges: edges, length: length))
    }
    func padding(when size: Set<UserInterfaceSizeClass>, _ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        self.modifier(AdaptivePaddingModifier(sizeClasses: size, edges: edges, length: length))
    }

}


#if os(macOS)

enum UserInterfaceSizeClass {
    case regular, compact
}


enum HorizontalSizeClassKey : EnvironmentKey {
    static var defaultValue: UserInterfaceSizeClass = .regular
}


extension EnvironmentValues {
    var horizontalSizeClass: UserInterfaceSizeClass {
        get { self[HorizontalSizeClassKey.self] }
        set {self[HorizontalSizeClassKey.self] =  newValue}
    }
}


#endif
