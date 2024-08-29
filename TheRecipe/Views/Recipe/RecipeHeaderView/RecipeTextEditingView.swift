//
//  RecipeSourceView.swift
//  TheRecipe
//
//  Created by Elena Zisina on 12/5/22.
//
 
import SwiftUI

struct RecipeTextEditingView: View {
    
    @Binding var entity : String

    var placeholder = "Add"
    @FocusState private var isFocused : Bool
   
    @State private var isEditingText = false
    
    var body: some View {
        
        HStack {
            if isEditingText {
                

                TextField(placeholder, text: $entity, prompt: Text(placeholder),axis: .vertical)
                    .onSubmit {
                        entity = entity
                        isFocused = false
                    }
                    .frame(maxWidth:.infinity, alignment:.leading)
                    .focused($isFocused, equals: true)
            } else {
                //Link("SwiftUI Tutorials", destination: URL(string: "https://www.simpleswiftguide.com")!)
                if entity.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.secondary)
                        .frame(maxWidth:.infinity, alignment:.leading)
                    
                } else {
                    Text(verbatim: entity)
                        .frame(maxWidth:.infinity, alignment:.leading)
                }
            }
            Spacer()
            
            Button(action: {editEntity()}) {
                Label("Edit", systemImage: "pencil")
                    .labelStyle(.iconOnly)
            }
           // .hidden(when: !isEditingText)
            .buttonStyle(.borderless)
            .foregroundColor(.accentColor)
            .fontWeight(.bold)
            
        }
        .contentShape(Rectangle())
        .onChange(of: isFocused) { newVal in
            
            DispatchQueue.main.async {
                if isFocused == false { isEditingText = false}
            }
        }
        .frame(maxWidth:.infinity, alignment: .leading)
        .onTapGesture(count:1, perform: {editEntity()})
        .onLongPressGesture {
            editEntity()
        }
      
    }
    
    
    private func editEntity() {
        DispatchQueue.main.async {
            isFocused.toggle()
            isEditingText.toggle()
            
        }
    }
}
