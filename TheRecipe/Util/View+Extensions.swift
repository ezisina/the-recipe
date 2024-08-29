//
//  View+Extensions.swift
//  TheRecipe
//

import SwiftUI


extension View {

    /// Hides the view when the condition is met.
    ///
    /// - Parameter condition: Condition to determine whether or not the view is hidden.
    ///
    /// - Returns: A hidden view if the condition is met, unmodified view otherwise.
    @ViewBuilder
    func hidden(when condition: Bool) -> some View {
        if condition {
            self.hidden()
        } else {
            self
        }
    }
    /// Conditional style
    ///
    /// - Parameter condition: Condition to determine what style uses.
    ///
    /// - Returns: self.buttonStyle()
    @ViewBuilder
    func conditionalButtonStyle(when condition: Bool, _ trueStyle: some PrimitiveButtonStyle, else falseStyle: some PrimitiveButtonStyle) -> some View {
        if condition {
            self.buttonStyle(trueStyle)
        } else {
            self.buttonStyle(falseStyle)
        }
    }
    //MARK: - Styles
    
    ///This style is using to unify section header's look.
    func sectionHeaderStyle() -> some View {
        self
            .font(.subheadline)
            .fontWeight(.medium)
            .textCase(.uppercase)
            .underlinedText()
            
    }
    func sheetTitleStyle() -> some View {
        self
            .font(.title3)
            .padding()
    }
    
    func underlinedText() -> some View {
        self
            .underline(pattern:.dashDotDot,color: .accentColor)
    }
    
    ///To make Text smaller and grey. This style useful for notes and accompanying texts
    func noteStyle() -> some View {
        self
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
    
    func closeBtnStyle() -> some View {
        self.padding()
            .background(Material.regular)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
//- MacOS extensions
#if os(macOS)
extension NSColor {
  static  var secondarySystemFill: NSColor {
         .clear
    }
}

extension View {
    func applyToolbarSetup() -> some View {
        self
            .toolbarRole(.automatic)
    }

}
#else
extension View {
    func applyToolbarSetup() -> some View {
        self
            .navigationBarTitleDisplayMode(.automatic)
            .toolbarRole(.navigationStack)
    }
}
#endif

struct MySection<Content> : View where Content:View {
    @ViewBuilder var content: Content
    var body: some View {
        if #available(macOS 13, *)  {
            content
        } else {
            Section { content }
        }
    }
}
