//
//  CopyrightView.swift
//  TheRecipe
//
//  Created by Elena Zisina on 10/11/23.
//
//FIXME: this is copyright. should be link to project page or something. and should be placed in the general
import SwiftUI

struct CopyrightView: View {
    var body: some View {
        VStack {
            (Text("@Iurii Zisin ")+Text("@Olena Zisina"))
            Text("Visit Apple: [click here](https://apple.com)")
                .tint(.accentColor)
        }
    }
}

#Preview {
    CopyrightView()
}
