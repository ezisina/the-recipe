//
//  AboutView.swift
//  TheRecipe
//
//  Created by Elena Zisina on 6/9/23.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        
        VStack(spacing:15) {
            Text("The-Recipe is light-weight and easy-going recipe organizer. You can make or hoard your favorite recipes here. Easy to create, find and use.")
            Link( destination: URL(string: "http://example.com")!) {
                Text("Special thanks to ") + Text("[Efsona](https://google.com.com)").underline(pattern:.dashDotDot,color: .accentColor) + Text(" for the beautiful background")
            }.foregroundColor(.primary)
                .font(.headline)
            
        }.padding()
        
        
    }
}

#Preview {
    AboutView()
}
