//
//  ApplicationFailureView.swift
//  The Recipe
//

import SwiftUI


/// The view that is presented in case of an unrecoverable error when the application cannot function.
///
/// Usually this kind of error means underlying Core Data storage failure.
struct ApplicationFailureView: View {
    var error: NSError
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Application Error", comment: "Title of ApplicationFailureView")
                .font(.title)
            
            Text("Unfortunately the application internal data is corrupt.", comment: "Text in ApplicationFailureView")
            Text("Please try re-installing the application.", comment: "Text in ApplicationFailureView")
            Text("We apologize for the inconvenience.", comment: "Text in ApplicationFailureView")
            
            VStack {
                Text("Error:", comment: "Error header just above the error text in ApplicationFailureView")
                Text(error.localizedDescription)
            }
            .padding(.vertical)
        }
        .padding()
        
        //FIXME: Need Contact Support
    }
}
