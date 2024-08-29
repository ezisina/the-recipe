//
//  TimeEditView.swift
//  TheRecipe
//
//  Created by Elena Zisina on 12/5/22.
//

import SwiftUI

struct TimeEditView: View {

    @Binding var time : Double
    
    var body: some View {
        VStack(spacing:0) {
            
            HStack(spacing:10) {
                    Stepper("\(time.hours)",value: $time.hours, in: 0...60)
                    .frame(minWidth:50, maxWidth: .infinity, alignment: .center)
                
                    Stepper("\(time.minutes)", value: $time.minutes, in: 0...60)
                    .frame( minWidth:50, maxWidth: .infinity, alignment: .center)
                
                    Stepper("\(time.seconds)",value: $time.seconds, in: 0...60)
                    .frame( minWidth:50, maxWidth: .infinity, alignment: .center)
                    .hidden(when: time.minutes > 5)
            }
            #if !os(macOS)
            .labelsHidden()
            #endif
            .font(.headline)
            .frame(maxWidth: .infinity)

            HStack(spacing:10){
                
                Text("hour:")
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("min:" ).frame(maxWidth: .infinity, alignment: .center)
                
                Text("sec:").frame(maxWidth: .infinity, alignment: .center)
                    .hidden(when: time.minutes > 5)
            }
            .font(.footnote)
           

        }
        .foregroundColor(.accentColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(.white)

#if os(macOS)
.padding()
.frame(width: 350, height: 200)
#endif
    }
}


struct TimeEditView_Previews: PreviewProvider {
    
    static var previews: some View {
        WrapperView()
    }
    
    struct WrapperView: View {
        @State private  var time : Double = 100.0
        var body: some View {
            TimeEditView(time: $time)
        }
        
    }
}
