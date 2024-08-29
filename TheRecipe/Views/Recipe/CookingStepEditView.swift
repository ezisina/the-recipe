//
//  CookingStepEditView.swift
//  TheRecipe
//

import SwiftUI
import PhotosUI

struct CookingStepEditView: View {
    @ObservedObject var step: CookingStep
    @ObservedObject var recipe: Recipe
    
    @State var pickedPhoto: PhotosPickerItem?
    @State private var previewingImage: RecipeImage?
    
    let rowColor = Color(.secondarySystemFill)
    var body: some View {
        
            EditingSheet("Instruction Step", editing: step) {
                Form {
                    Section {
                        VStack(spacing:-10) {

                            TimeEditView(time: $step.time)
                        }
                        .listRowBackground( rowColor )
                    } header: {
                        LabeledContent {
                            Text("\(step.time.humanReadableTime)")
                                .foregroundColor(.accentColor)
                        } label: {
                            Text("Preparation Time")
                                .sectionHeaderStyle()
                        }
                    } footer: {
                        Text("Only set the time that is needed for this particular step. It will define the reminder timer in Cooking Mode.")
                    }.listSectionSeparator(.hidden)
                     .listRowSeparator(.hidden)
                     
                    Section {
                        TextField("Directions", text: $step.wrappedDirections, axis: .vertical)
                            .lineLimit(2...10)
                            .listRowBackground( rowColor )
                    } header: {
                        Text("Directions")
                            .sectionHeaderStyle()
                    } footer: {
                        Text("Describe what exactly needs to be done in this preparation step. Try not to involve more than one operation per step — you can create as many steps as you need.")
                    }
                    
                    Section {
                        ForEach(recipe.wrappedIngredients.ordered) { ingredient in
                            Button {
                                toggleIngredient(ingredient)
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark")
                                        .hidden(when: !(ingredient.canBeUsed(inCookingStep: step) && ingredient.isInUse(inCookingStep: step)))
                                        .foregroundColor(.accentColor)
                                    IngredientView(ingredient: ingredient)
                                        .strikethrough(!ingredient.canBeUsed(inCookingStep: step))
                                }
                            }
                            .disabled(!ingredient.canBeUsed(inCookingStep: step))
                        }
                        .listRowBackground( rowColor )
                        .buttonStyle(.plain)
                    } header: {
                        Text("Ingredients Involved")
                            .sectionHeaderStyle()
                    }
                    Section {
                        List(step.wrappedImages.ordered, selection: $previewingImage) { image in
                            HStack{
                                Spacer()
                                Image(kitImage: image.kitImage!)
                                    .resizable()
                                    .frame(width:150, height:150)
                                    .swipeActions {
                                        Button("Delete", role: .destructive) {
                                            deletePhoto(image)
                                        }
                                    }
                                Spacer()
                            }.listRowBackground( rowColor )
                        }
                        
                        
                    } header: {
                        LabeledContent {
                            PhotosPicker(selection: $pickedPhoto) {
                                Text("+").font(.title)
                            }
                        } label: {
                            Text("Images (\(step.wrappedImages.count))")
                                .sectionHeaderStyle()
                            
                        }.foregroundColor(.accentColor)
                        
                    } footer: {
                        Text("Tap **+** to add a picture.")
                    }
                }
            }
            .onChange(of: pickedPhoto) {
                addPhoto($0)
            }
            .scrollContentBackground(.hidden)
            
    }
    //TODO: lower bound should >= 0
    func decrementStep(for value: Binding<Int>) {
        if value.wrappedValue > 1 {
            value.wrappedValue -= 1
        }
    }
    
    private func toggleIngredient(_ ingredient: RecipeIngredient) {
        if step.wrappedIngredients.contains(ingredient) {
            step.wrappedIngredients.remove(ingredient)
        } else {
            step.wrappedIngredients.insert(ingredient)
        }
    }
    
    @MainActor
    func addPhoto(_ newPhoto: PhotosPickerItem?) {
        guard let newPhoto = newPhoto else {
            return
        }
        Task {
            guard let context = recipe.managedObjectContext, let data = try? await newPhoto.loadTransferable(type: Data.self) else {
                return
            }
            await context.perform {
                let image = recipe.addImage()
                image.image = data
                image.cookingStep = step
                
            }
        }
    }
    
    func deletePhoto(_ image : RecipeImage) {
        guard let context = image.managedObjectContext else {
            return
        }
        context.delete(image)
    }
}




#Preview {
    let recipe = Recipe.firstForPreview(predicate: .init(format: "title = 'Angel Face'"))
    return CookingStepEditView(step: recipe.wrappedCookingSteps.first!, recipe: recipe)
}
