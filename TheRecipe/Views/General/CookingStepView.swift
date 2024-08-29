//
//  CookingStepView.swift
//  TheRecipe
//

import SwiftUI


struct CookingStepView: View {
    
    
    @ObservedObject var step: CookingStep
    @FocusState private var isEditing : Bool
   
    @State private var isEditingDirection = false
    
    var body: some View {
        Group {
            HStack(alignment: .top, spacing: 8) {
                VStack {
                    Text(Image(systemName: "\(step.order+1).circle")
                       // .renderingMode(.original)
                    )
                    .foregroundColor(.accentColor)
                    Spacer(minLength: 8)
                    if (isEditingDirection) {
                        Button(role:.destructive,action: {finishEditing()}) {
                            Label("Save", systemImage: "checkmark")
                                .labelStyle(.iconOnly)
                                .bold()
                        }.foregroundColor(.accentColor)
                    }
                }
                if (isEditingDirection) {
                    VStack(alignment:.leading, spacing : 0) {
                        TextEditor(text: $step.wrappedDirections)
                        //FIXME: add background color or somehow show editing...
                            .transition(.opacity)
                            .focused($isEditing)
                            .padding(.top, -10)
                            //.background(.secondary)
                            .onSubmit {
                                finishEditing()
                            }
                        Text("Add Step Direction", comment: "Hint for Add Direction Field") // This is a Hint
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text(step.wrappedDirections)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if step.time > 0 {
                        Text("\(step.time.humanReadableTime)")
                            .noteStyle()
                    }
                }
            }.onTapGesture(count: 2) {
                
                DispatchQueue.main.async {
                    isEditingDirection.toggle()
                    isEditing.toggle()
                }
            }
            .onChange(of: isEditing) { newValue in
                
                DispatchQueue.main.async {
                    if isEditing == false { isEditingDirection = false}
                }
            }
            //FIXME: photo gallery
            if step.wrappedImages.count > 0  && false {
                HStack{
                    
                    ForEach(step.wrappedImages.ordered) { image in
                        
                        Image(kitImage: image.kitImage!)
                            .resizable()
                            .frame(width:50, height:50)
                            .onTapGesture {
                                print("open in bigger screen")
                            }
                        
                    }
                }
            }
        }
    }
    
    func finishEditing() {
        step.wrappedDirections = step.wrappedDirections.trimmingCharacters(in: .whitespacesAndNewlines )
        isEditing = false
    }
}



struct CookingStepView_Previews: PreviewProvider {
    static var previews: some View {
        CookingStepView(step: CookingStep.firstForPreview())
    }
}
