//
//  RecipeHeader.swift
//  TheRecipe
//

import SwiftUI
import PhotosUI

struct RecipeHeaderView: View {
    @ObservedObject var recipe: Recipe
    //FIXME: Prevent  updating Title and stars in the header
    //so, commented vm until photos will be added
    //@StateObject private var vm: ViewModel
    @State var pickedPhoto: PhotosPickerItem?
    @Binding var showChangeRatingPopover: Bool
    @Environment(\.managedObjectContext) private var viewContext
    
    init(recipe: Recipe, showChangeRatingPopover : Binding<Bool>) {
        self.recipe = recipe
        //_vm = StateObject(wrappedValue: ViewModel(recipe: recipe))
        self._showChangeRatingPopover = showChangeRatingPopover
    }
    
    var body: some View {
//        ZStack(alignment: .bottomTrailing) {
//            PhotosPicker(selection: $pickedPhoto) {
//                HStack(spacing: 0) {
//                    ForEach(vm.images, id: \.self) { image in
//                        Image(kitImage: image)
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .foregroundColor(.gray)
//                            .frame(maxHeight: 150)
//                            .frame(maxWidth: .infinity)
//                            .clipped()
//                    }
//                }
//            }
        VStack(alignment: .leading, spacing: 0) {
            LabeledContent {
//                Button(action: addPhoto) {
//                    Label("Add a Photo", systemImage: "photo.artframe")
//                        .labelStyle(.iconOnly)
//                }
               
                Button("\(recipe.rating)★")  {
                    showChangeRatingPopover = true
                }
                .popover(isPresented: $showChangeRatingPopover, attachmentAnchor: .point(.center)) {
                    RatingEditView(rating: $recipe.rating )
                        .presentationDetents([.medium])
                }
                .foregroundColor(.accentColor)
                .labelStyle(.titleAndIcon)
#if os(macOS)
                .buttonStyle(.accessoryBar)
#endif
            } label: {
                RecipeTextEditingView(entity: $recipe.wrappedTitle, placeholder: "New Recipe")
//                Text(recipe.wrappedTitle)
                    .font(.title)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                //.padding(.horizontal)
                   // .frame(alignment: .bottomTrailing)
                //                .colorInvert()
                //                .shadow(color: Color.primary , radius: 1)
                //                .colorInvert()
            }
           
//            .onChange(of: pickedPhoto) {
//                vm.addPhoto($0)
//            }
            //PhotoGallery(source: vm.recipe.wrappedImages)
            
           
        }
    }

    
    func addPhoto() {
        //TODO: Add photo Picker
        print("TODO: Add photo Picker")
    }

}



