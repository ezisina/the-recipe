//
//  RatingViews.swift
//  TheRecipe
//
//  Created by Elena Zisina on 1/11/23.
//

import SwiftUI

struct RatingEditView : View {
    @Binding var rating : Int16
    var body: some View {
        VStack(alignment:.leading, spacing: 0) {
            HStack {
                Text("How good the recipe is?", comment:"Title for Edit Rating")
                Spacer()
                
            }.font(.title3)
            .padding()

            Form {
                Section {
                    HStack(alignment:.top) {
                        Spacer()
                        ForEach(1..<6) { star in
                            Button(action: {setRating(stars: star) }) {
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(star > rating ? .secondary : .accentColor)
                            }.frame(width: 40)
                            .buttonStyle(.borderless) // !!! This is help tap on button not row
                        }
                        .flipsForRightToLeftLayoutDirection(true)
                        Spacer()
                    }

                }
                .frame(maxWidth: .infinity)
                
            }
        }
        #if os(macOS)
        .padding()
        #endif
        #if os(iOS)
        .frame(width: 350, height: 200) 
        #endif
    

    }
    
    private func setRating(stars : Int) {
        withAnimation {
            $rating.wrappedValue = Int16(stars)
        }
    }
}

struct RatingViewShort : View {
    var rating : Int16
    
    var body: some View {
        HStack(alignment:.lastTextBaseline, spacing: 0){
            Text("\(rating)★")
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
}

struct RatingEditView_Previews: PreviewProvider {
    
    static var previews: some View {
        WrapperView()
    }
    
    struct WrapperView: View {
        @State private var rating : Int16 = 3
        var body: some View {
            RatingEditView(rating: $rating)
        }
        
    }
}
