//
//  RecipePreviewView.swift
//  TheRecipe
//
//  Created by Elena Zisina on 5/25/23.
//

import SwiftUI

@MainActor
struct RecipePreviewView: View {
    @ObservedObject var recipe: Recipe
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State var isFullScreenPhoto = false
    @State var editRecipeSheet = false
    @State private var cookRecipeSheet = false
    @State private var showTagsPicker = false
    @State var showingImage : KitImage?
    @State private var autocompleteSelection: AutocompleteSelection<Tag> = .none
    @State private var showChangeRatingPopover: Bool = false
    
    @FetchRequest(sortDescriptors: [//SortDescriptor(\Tag.recipeModifiedDate, order: .reverse),
        SortDescriptor(\Tag.name, order: .forward),
        SortDescriptor(\Tag.recipesCount, order: .reverse),
                                   ],
                  predicate: NSPredicate(format: "%K > 0", #keyPath(Tag.recipesCount)))
    private var tags: FetchedResults<Tag>
    
    @State var recipeCopy : Recipe?
    
    @State private var isPlayerIsPlaying: Bool? = nil
    
    let testUrl:String = "https://www.youtube.com/watch?v=wiVlScPkWfc&list=RDCMUC0lG3Ihe4LGV851lODRIS5g&index=6"//"https://youtu.be/wiVlScPkWfc?si=uLh5dSyYfASxLtMf"
    //"http://31.148.48.15:80/A1/index.m3u8?token=test"
    @State private var startedSecs : Binding<Double> = .constant(0.0)
    #if !os(macOS)
    private let pastboard = UIPasteboard.general
    #endif
    var body: some View {
        let videoUrl = URL(string: recipe.wrappedVideoUrl)
        NavigationStack {
            VStack(alignment: .leading) {
                ScrollView(.vertical) {
                    contentbody
                        .background(Color.clear.background(.ultraThinMaterial), alignment: .center)
                        .clipShape(
                            
                            // 1
                            RoundedRectangle(
                                cornerRadius: 8
                            ))
                    //FIXME: Show link on Video if VideoPlayer can't play it
                    if videoUrl != nil && !(isPlayerIsPlaying ?? false) {
                        Link( destination: videoUrl!) {
                            
                            Text("Recipe Video: \(videoUrl!.absoluteString)").underline(pattern:.dashDotDot,color: .accentColor)
                                .contextMenu {
                                    Button {
                                    #if os(macOS)
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.addTypes([.string], owner: nil)
                                        NSPasteboard.general.setString(videoUrl!.absoluteString, forType: .string)
                                    #else
                                        pastboard.string = videoUrl!.absoluteString
                                    #endif
                                    } label: {
                                        Text("Copy")
                                    }
                                }
                            
                        }
                        .frame(alignment: .leading)
                        .sectionHeaderStyle()
                    } else if videoUrl != nil && (isPlayerIsPlaying ?? false) {

                        VideoFork(url: videoUrl!, startVideoAtSeconds: startedSecs, muted: .constant(true), isReadyForDisplay: $isPlayerIsPlaying)
                            .frame(width: 300)
                    } else {
                        EmptyView()
                    }
                }
                
            }
            .padding(.horizontal)
            
#if !os(macOS)

            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.navigationStack)
#else
            .frame(minWidth:300, minHeight: 400)
#endif
            .toolbar{
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Cook step-by-step", systemImage: "play.fill") {
                            toCookRecipe()
                        }
                        Button("Edit", systemImage: "pencil") {
                            toEditRecipe()
                        }
                        ShareLink("Export PDF", item: render())

                        Button("Alter", systemImage: "rectangle.and.pencil.and.ellipsis") {
                            toAlterRecipe()
                        }.hidden()
                    } label: {
                        Label("Actions", systemImage: "ellipsis")
                            .labelStyle(.titleAndIcon)
                        
                    }
                    .menuStyle(.button)
                    .buttonStyle(.borderless)
                    .foregroundColor(.accentColor)
                    
                    
                }
#if os(iOS)
                //                ToolbarItem(placement: .cancellationAction) {
                //                    Button(action:{dismiss()}) {
                //                        Label("Close", systemImage: "xmark").labelStyle(.titleAndIcon)
                //                    }
                //                    .foregroundColor(.accentColor)
                //                }
#endif
            }
            .sheet(isPresented: $isFullScreenPhoto, onDismiss: didDismissFullscreenPhotoView) {
                VStack {
                    FullscreenPhotoView(image: showingImage ?? KitImage())
                }
                
            }
            .sheet(isPresented: $editRecipeSheet) {
                NavigationStack {
                    RecipeView(recipe: recipe)
                        .background( backgroundImage.ignoresSafeArea())
                }
            }
            .sheet(isPresented: $cookRecipeSheet) {
                //Added navigation stack to see Navbar in sheet 
                NavigationStack {
                    CookingView(recipe: recipe)
                        .background( backgroundImage.ignoresSafeArea())
                }
            }
            .sheet(isPresented: $showTagsPicker) {
                NavigationStack {
                    TagsEditView(provider: recipe)
                }
            }
            .sheet(item: $recipeCopy) { copy in
                NavigationStack {
                    RecipeView(recipe: copy)
                        .background( backgroundImage.ignoresSafeArea())
                }
            }
            //            .onChange(of: autocompleteSelection) { newValue in
            //                print("picked tag ",newValue)
            //            }
            .onChange(of: isPlayerIsPlaying) { isReady in
                guard let isReady = isReady else {
                    return
                }
                
            }
        }
    }
    
    var contentbody : some View {
        VStack(spacing:10) {

            VStack(alignment: .leading) {
                #if os(macOS)
                Text(recipe.title ?? "No title")
                    .font(.title)
                #endif
             
                LabeledContent {
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
                    Text(recipe.title ?? "No title")
                        .font(.title)
                }
                
                AdaptiveLayout(hAlignment: .leading, vAlignment: .top, spacing: .single(20)) {
                    let url = URL(string: recipe.wrappedSource)
                    if (!(recipe.wrappedSource.isEmpty ) && url != nil) {
                        Link(url!.host(percentEncoded: false) ?? "", destination: url!)
                    }
                    ViewThatFits {
                        VStack(alignment: .leading) {
                            if ((recipe.cookingTime + recipe.preparationTime) > 0) {
                                Text("Total time: ").font(.headline)+Text("\((recipe.cookingTime+recipe.preparationTime).humanReadableTime)").font(.subheadline)
                                
                            }
                            if (recipe.preparationTime > 0) {
                                Text("Preparation time: ").font(.headline)+Text("\(recipe.preparationTime.humanReadableTime)").font(.subheadline)
                                
                            }
                            if (recipe.servings > 0) {
                                Text("Servings: ").font(.headline)+Text("\(recipe.servings)").font(.subheadline)
                            }
                            if (!recipe.wrappedMakes.isEmpty) {
                                Text("Makes: ").font(.headline)+Text("\(recipe.wrappedMakes)").font(.subheadline)
                                
                            }
                        }
                        HStack() {
                            if ((recipe.cookingTime + recipe.preparationTime) > 0) {
                                Text("Total time: ").font(.headline)+Text("\((recipe.cookingTime+recipe.preparationTime).humanReadableTime)").font(.subheadline)
                                Divider()
                            }
                            if (recipe.preparationTime > 0) {
                                Text("Preparation time: ").font(.headline)+Text("\(recipe.preparationTime.humanReadableTime)").font(.subheadline)
                                Divider()
                            }
                            if (recipe.servings > 0) {
                                Text("Servings: ").font(.headline)+Text("\(recipe.servings)").font(.subheadline)
                                Divider()
                            }
                            if (!recipe.wrappedMakes.isEmpty) {
                                Text("Makes: ").font(.headline)+Text("\(recipe.wrappedMakes)").font(.subheadline)
                            }
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    //.sectionHeaderStyle()
                }
                
                if (!recipe.wrappedSummary.isEmpty) {
                    Text(recipe.wrappedSummary)
                        .font(.headline)
                }
                
                AdaptiveLayout(hAlignment: .leading, vAlignment: .top, spacing: .single(20)) {
                    VStack(alignment:.leading, spacing: 4) {
                        ForEach(recipe.wrappedIngredients.ordered) { ingredient in
                            IngredientView(ingredient: ingredient)
                        }
                    }
//                    .padding(when: .regular, .vertical)
//                    .padding(when: .compact, .vertical)
                    
                    Divider().overlay(Color.accentColor)
                    VStack(alignment:.leading, spacing: 4) {
                        ForEach(recipe.wrappedCookingSteps.ordered) { step in
                            VStack(spacing: 4) {
                                if (!step.wrappedIngredientsAsString.isEmpty) {
                                    HStack {
                                        
                                        Text("will use ")+Text(step.wrappedIngredientsAsString)
                                            .bold()
                                            .italic()
                                            .underline(pattern:.dashDotDot,color: .accentColor)
                                        
                                    }
                                }
                                CookingStepView(step: step)
                                    .fixedSize(horizontal: false, vertical: true)
                                if (step.wrappedImages.count > 0) {
                                    CarouselView(source: step.wrappedImages, onTapAction: {isFullScreenPhoto = true}, tappedImage: $showingImage)
                                    
                                }
                            }
                        }
//                        if (!(recipe.comment ?? "").isEmpty ) {
//                            (Text("Notes:").font(.headline)+Text(recipe.comment!).font(.subheadline))
//                                .padding()
//                            
//                        }

                    }.textSelection(.enabled)
                }
                .padding(when: .regular, .vertical)
                .padding(when: .compact, .vertical)
            }
            .padding([.horizontal, .top])
            VStack(alignment: .leading) {
                LabeledContent {
                    
                } label: {
                    Text("Notes")
                        .sectionHeaderStyle()
                }
                //TODO: add TextEdit here for new notes
                //Text("TODO: Add notes")
                RecipeTextEditingView(entity: $recipe.wrappedComment, placeholder: "Add some notes here")
            }
            .padding([.horizontal])
            
            VStack {
                TagsListView(provider: recipe)
                    
            }
            .padding([.horizontal,.bottom, .top])

        }
        .padding([.horizontal])
        
    }
    
    var contentbodyForExport : some View {
        VStack {
            //Text(recipe.title ?? "the recipe").font(.largeTitle)
            contentbody
            VStack {
                TagCloudView(provider: recipe)
                    .padding(.horizontal)
            }
            CopyrightView()
            
        }
        .padding(.vertical)
    }
    
    func didDismissFullscreenPhotoView() {
        showingImage = KitImage()
    }
    
    func toEditRecipe() {
        //FIXME: make Navigation to RecipeView
        editRecipeSheet = true
    }
    func toCookRecipe() {
        //FIXME: make Navigation to CookingView
        cookRecipeSheet = true
    }
    
    func toAlterRecipe() {
        print("todo: make recipe alternation")
        recipeCopy = recipe.copyIt()
    }
    func render() -> URL {
        
        // 1: Render content view
        let renderer = ImageRenderer(content: contentbodyForExport)
        // 2: Save it to our documents directory
        let url = URL.documentsDirectory.appending(path: "\(recipe.title ?? "therecipe").pdf")
        // 3: Start the rendering process
        renderer.render { size, context in
            // 4: Tell SwiftUI our PDF should be the same size as the views we're rendering
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)

            // 5: Create the CGContext for our PDF pages
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                return
            }

            // 6: Start a new PDF page
            pdf.beginPDFPage(nil)

            // 7: Render the SwiftUI view data onto the page
            context(pdf)

            // 8: End the page and close the file
            pdf.endPDFPage()
            pdf.closePDF()
        }
        return url
    }
}

#Preview {
    let recipe = Recipe.firstForPreview(predicate: .init(format: "title = 'Michelada'"))
    return RecipePreviewView(recipe: recipe)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}


//TODO: 1  port/add  comments into different table

