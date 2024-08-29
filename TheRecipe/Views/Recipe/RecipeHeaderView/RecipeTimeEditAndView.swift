//
//  RecipeTimeEditView.swift
//  TheRecipe
//
//  Created by Elena Zisina on 11/29/22.
//

import SwiftUI

struct RecipeTimeEditAndView : View {
   
    @Binding var time : Double
    var title : String

    @Binding var showTimeEditingSheet : Bool
    
    var body: some View {
        HStack {

            Text("\(time.humanReadableTime)", comment: "0:0")
                .foregroundColor(.primary)
                .font(.subheadline)
            Spacer()
            Button(action: {showTimeEditingSheet.toggle()}) {
                Label("Edit", systemImage: "pencil")
                    .labelStyle(.iconOnly)
            }.buttonStyle(.borderless)
                .foregroundColor(.accentColor)
        }
        .contentShape(Rectangle())
        .onTapGesture(count:1) {
            showTimeEditingSheet.toggle()
        }
        .sheet(isPresented: $showTimeEditingSheet) {
            TimeEditFormView(time: $time, title: title)
                .presentationDetents([.medium])
        } 
    }
    

}

struct TimeEditFormView : View {
    @Binding var time : Double
    var title : String
 
    var body: some View {
        VStack {
            HStack {
                Text(title)
                Spacer()
                Text("\(time.humanReadableTime)")
                    .foregroundColor(.accentColor)
                    
            }.font(.title3)
            .padding()
            
            Form {
                Section {
                    TimeEditView(time: $time)
                }
            }
        }
    }
}
