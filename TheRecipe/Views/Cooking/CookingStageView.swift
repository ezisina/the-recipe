//
//  CookingStageView.swift
//  TheRecipe
//
//  Created by Elena Zisina on 7/20/22.
//

import SwiftUI

struct CookingStageView: View {
    @ObservedObject var step : CookingStep
    var nextStepDirections : String?
    @State private var isTimerStarted = false
    @State private var timeElapsed  = 0.0
    let rowColor = Color(.secondarySystemFill)
    //@State private var isPresentedFullScreenImage = false
    @State private var selectedImage : KitImage?
    var body : some View {
        
            Form {
                Section {

                    Text(step.wrappedDirections)
                        .font(.title)
                        .padding()
                        .listRowSeparator(.hidden)
                        .listRowBackground( rowColor )
                    
                } header: {
                    
                    LabeledContent {
                        if (step.time > 0) {
                            HStack {
                                cookingTimer
                                    .noteStyle()
                            }
                        }

                    } label: {
                        
                        if (!step.wrappedIngredientsAsString.isEmpty) {
                            HStack {
                                
                                Text("will use ")+Text(step.wrappedIngredientsAsString)
                                    .bold()
                                    .italic()
                                    .underline(pattern:.dashDotDot,color: .accentColor)
    
                            }
                        }
                    }
                    
                    
                    
                    
                } footer: {
                    if let text = nextStepDirections {
                        nextStepView(text)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    if (step.wrappedImages.count>0) {
                        Button {
                            showGallery()
                        } label: {
                            Label("Gallery", systemImage: "photo.artframe")
                        }
                    }
                }
                
            }
        
//            if (step.wrappedImages.count>0) {
                
//                stepImages
//                    .padding(.horizontal)
//                    .padding(.bottom, 40)
//            }
        
    }
    func showGallery() {
        
    }
    private func nextStepView(_ text : String) ->  some View {

        VStack{
            
            Text("Next step: ").bold()
            Text(text).italic()
           
        }
        .padding()
        .multilineTextAlignment(.center)
        .frame(maxWidth:.infinity, minHeight: 50)

    }
    
    private var cookingTimer: some View {
        Group {
            if (step.time > 0) {
                Label("\(step.time.humanReadableTime)", systemImage: "clock")
                // TODO: add timer
                //        TimerView(timeElapsed: $timeElapsed, notifyAfter: step.time) {
                //            print("TIME!")
                //        }
            } else {
                EmptyView()
            }
        }
    }
    //TODO: show in gallery on tap 
    private var stepImages : some View {
        
           
            CarouselView(source: step.wrappedImages, tappedImage: $selectedImage)

          /*  ScrollView(.horizontal) {
                HStack {
                    ForEach(step.wrappedImages.ordered, id: \.self) { image in
                        Image(kitImage: image.kitImage!)
                            .resizable()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .aspectRatio(1.0, contentMode: .fit)
                            .cornerRadius(10)
                            .border(Color.white, width: 0.75)
                            .clipped()
                            .onTapGesture {
                                isPresentedFullScreenImage.toggle()
                            }
                            .fullScreenCover(isPresented: $isPresentedFullScreenImage, onDismiss: {}) {
                                PhotoGallery(source: step.wrappedImages, showingImage: image.kitImage)
                                //FullscreenPhotoView(image: image.kitImage!)
                            }
                    }.listRowSeparator(.hidden)
                    
                }.shadow(radius: 2)
           }
           */
            
//        }  footer: {
//            Text("Tap to see in gallery")
        
        

    }
}

#Preview {
    Group {
        let recipe = Recipe.firstForPreview()
        if let step = recipe.wrappedCookingSteps.ordered.first {
            CookingStageView(step: step)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        } else {
            Text("No steps found")
        }
    }
}
