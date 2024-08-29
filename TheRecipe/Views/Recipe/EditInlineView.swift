//
//  EditInline.swift
//  TheRecipe
//
//  Created by Elena Zisina on 5/22/23.
//
import Foundation
import SwiftUI

struct EditInlineView: View {
    @Binding var textForEdit: String
    @State private var stepsCount: Int = 0
    var title: String = "Directions"

    var body: some View {
        VStack {
            HStack {
                Text("\(title)")
                
            }
            .font(.title3)
            .padding()
            Form {
                Section {
                    
                    TextEditor(text: $textForEdit)
                        .frame( height: 300, alignment: .leading)
                        .lineLimit(10)

                } header: {
                    Text("All ")+Text("\(title.localizedCapitalized)").fontWeight(.semibold)+Text(" in one view for parsing next:")
                }
            }.frame(maxHeight: .infinity)
        }
#if os(macOS)
.padding()
.frame(width: 350, height: 400)
#endif
    }

}

//struct EditInline_Previews: PreviewProvider {
//    static var previews: some View {
//        EditInline(textForEdit: Binding<String>)
//    }
//}
