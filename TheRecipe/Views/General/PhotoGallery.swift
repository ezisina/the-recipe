//
//  PhotoGallery.swift
//  TheRecipe
//
//  Created by Elena Zisina on 8/17/22.
//NOTE: how to write image to Potos
//NOTE: tutorial from apple https://developer.apple.com/tutorials/sample-apps/imagegallery
import SwiftUI

struct PhotoGallery: View {
    @Environment(\.dismiss) private var dismiss
    
    var source : Set<RecipeImage>
    
    @State  var showingImage : KitImage?
    var body: some View {
        let image = showingImage ?? KitImage()
        NavigationStack {
            ZStack {
                Color.red
                FullscreenPhotoView(image: image)
                VStack {
                    Spacer()
                    CarouselView(
                        source: source,
                        onTapAction: {},
                        orientation: .horizontal,
                        tappedImage: $showingImage
                    )
                        .frame(height:100)
                }
            }.ignoresSafeArea()
            .toolbar{
                Button(action: {dismiss()}){
                    Image(systemName: "xmark")
                }
            }
        }
    }
    /*
    var photoCarousel : some View {

        ScrollView(.horizontal) {
            HStack {
                ForEach(source.ordered, id: \.self) { image in
                    Image(kitImage: image.kitImage!)
                        .resizable()
                        .frame(maxWidth: 80, maxHeight: 80)
                        .aspectRatio(1.0, contentMode: .fit)
                        .cornerRadius(10)
                    
                        .border(Color.white, width: 0.75)
                        .clipped()
                        .onTapGesture {
                            $showingImage.wrappedValue = image.kitImage
                        }
                    
                }.listRowSeparator(.hidden)
                
            }.shadow(radius: 2)
        }
        
    }
     */
}
//
//struct PhotoGallery_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoGallery(source: Set())
//    }
//}
struct CarouselView : View {
    var source : Set<RecipeImage>
    var onTapAction : () -> Void = { }
    var orientation : Axis.Set = .horizontal
    @Binding var tappedImage : KitImage?
    
    var body: some View {
        ScrollView(orientation) {
            HStack {
                ForEach(source.ordered, id: \.self) { image in
                    if (image.imageUrl?.isEmpty ?? true) {
                        //FIXME: Image might be online and load from imageUrl with licenseUrl
                        Image(kitImage: image.kitImage!)
                            .resizable()
                            .frame(maxWidth: 80, maxHeight: 80)
                            .aspectRatio(1.0, contentMode: .fit)
                            .cornerRadius(10)
                        
                            .border( Color.white, width: 0.75)
                            .clipped()
                            .onTapGesture {
                                $tappedImage.wrappedValue = image.kitImage
                                onTapAction()
                            }
                    } else {
                        
                        ImageWLicense(image: image)
                    }
                    
                }.listRowSeparator(.hidden)
                
            }.shadow(radius: 2)
        }
    }
}
struct ImageWLicense : View {
    var image : RecipeImage?
    var imageUrl: String?
    
    var body: some View {
        VStack {
//            Text(image?.imageUrl ?? "NA url")
            let url = URL(string: image?.imageUrl ?? imageUrl ?? "https://upload.wikimedia.org/wikipedia/commons/6/67/Carl_Saltzmann_-_View_of_Acapulco%2C_1879.jpg")
            
            let lurl = URL(string: image?.licenseUrl ?? "https://creativecommons.org/licenses/by/4.0/deed.en")
//            Text(url?.absoluteString ?? "NA url")
            Link(destination: lurl!) {
                AsyncImage(url: url!) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit) // Displays the loaded image.
                    } else if phase.error != nil {
                        Text("\(phase.error!.localizedDescription)")
                        Color.red // Indicates an error.
                    } else {
                        ProgressView() // Acts as a placeholder.
                    }
                     
                } .frame(width: 500)
                    .overlay(alignment: .bottom) {
                        (Text("License: ")+Text(lurl?.absoluteString ?? "https://creativecommons.org/licenses/by/4.0/deed.en"))
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth:.infinity)
                            .background(Material.ultraThinMaterial)
                            .foregroundColor(.primary)
                    }
            }
        }
    }
}

struct ImageWLicense_Previews: PreviewProvider {
    
    static var previews: some View {
        WrapperView()
    }
    
    struct WrapperView: View {
        
        @State private static var recipe = Recipe.firstForPreview()
        var body: some View {
            ImageWLicense(image: ImageWLicense_Previews.WrapperView.recipe.wrappedImages.first)
        }
        
    }
}
struct FullscreenPhotoView : View {
    

    var image: KitImage
    @State private var currentAmount = 1.0
    @State private var finalAmount = 1.0
    
    // how far the circle has been dragged
    @State private var offset = CGSize.zero

    var magnification: some Gesture {
        MagnificationGesture()
           .onChanged { value in
               currentAmount = finalAmount * value.magnitude
               currentAmount = min(max(currentAmount, 1.0), 2.5)
           }
           .onEnded { amount in
               finalAmount = currentAmount
           }
    }
    
    var body : some View {
        // a drag gesture that updates offset and isDragging as it moves around
        let dragGesture = DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { _ in
                withAnimation {
                    //offset = .zero
                    //isDragging = false
                }
            }

        // a combined gesture that forces the user to long press then drag
        //let combined = pressGesture.sequenced(before: dragGesture)
       
           
                Image(kitImage: image)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .ignoresSafeArea()
                    .scaleEffect(currentAmount)
                    .offset(offset)
                    .gesture(dragGesture)
                    .gesture(magnification)
                
                
            .toolbar{
                Button(action: {currentAmount = 1.0}){
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                }
                
        }
    }
}
