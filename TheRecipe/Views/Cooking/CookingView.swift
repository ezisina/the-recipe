//
//  CookingView.swift
//  The Recipe
//


//TODO: add TimerView/Alarm to the step

import SwiftUI

struct CookingView: View {
    @ObservedObject var recipe: Recipe
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selection = 0
    
    @State private var showCancelConfirmation = false
    
    @StateObject private var speaker = Speaker()
    @ObservedObject private var recognizer = SpeechRecognizer.shared
    
    var body: some View {
        NavigationStack {
            ZStack {

                cookingStepsLayout
                    .padding(.top)
                    
                cookingProgress
                    
            }
//            .background(Color(.systemGroupedBackground))
            .navigationTitle(recipe.wrappedTitle)
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.browser)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        guard selection != recipe.wrappedCookingSteps.count+1 else {
                            dismiss()
                            return
                        }
                        showCancelConfirmation = true
                    }.foregroundColor(.accentColor)
                    .confirmationDialog("Are you sure?", isPresented: $showCancelConfirmation) {
                        Button("Stop and Close", action: dismiss.callAsFunction)
                    }
                }
#if !os(macOS)
                ToolbarItem(placement: .automatic) {
                    Button(action: speakerToggle) {
                        Label("Speak", systemImage:
                                speaker.state == .inactive ?
                              "speaker" : "speaker.wave.3")
                    }

                }
#endif
            }
            
        }
        .onAppear {
            selection = recipe.wrappedIngredients.count > 0 ? 0 : 1
        }
        .onChange(of: selection) { value in
            guard speaker.shouldSpeakUpStep else {
                return
            }
            speakStep(value)
        }
        .onReceive(recognizer.objectWillChange) { _ in
            print(recognizer.message)
            //FIXME: add Help or Hint to speach recognizer
            //FIXME: fix next or prev page. Now it's not next but over 1 step
            let message = recognizer.message.lowercased()
           
            if message.hasSuffix("next") {
                recognizer.stop()
                withAnimation {
//                    if selection < (recipe.cookingSteps?.count ?? 0) {
                        selection = min(selection+1,(recipe.cookingSteps?.count ?? 0))
//                    }
                }
            }
            
            if message.hasPrefix("again") || message.hasPrefix("repeat"){
                recognizer.stop()
                //withAnimation{
                    speakStep(selection)
               // }
            }
            
            if message.hasPrefix("stop") || message.hasPrefix("cancel") {
                recognizer.stop()
                
            }
            
            //again, repeat, back, go next
            if message.hasSuffix("go back") || message.hasSuffix("back") {
                recognizer.stop()
                withAnimation {
                    selection = max(0, selection-1)
                }
            }
        }
        .onDisappear() {
            speaker.stop()
            recognizer.stop()
            speakerOff()
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 400)
        #endif
    }
    
    private var cookingStepsLayout: some View {
        TabView(selection: $selection) {
            if (recipe.wrappedIngredients.count > 0) {
                IngredientsStageView(recipe: recipe)
                    .tag(0)
            }
            ForEach(recipe.wrappedCookingSteps.ordered) {step in
                CookingStageView(step: step, nextStepDirections: getNextStepDirections(current: step))
                    .listStyle(.inset)
                    .tag(step.wrappedOrder+1)
                
            }
            Text("Good session")
                .font(.title)
                .tag(recipe.wrappedCookingSteps.count+1)
        }
        .scrollContentBackground(.hidden)
        #if !os(macOS)
        .tabViewStyle(.page(indexDisplayMode: .never)) //FIXME: mac
        #endif
    }
    
    /**
     This is the cooking process's progress view
     */
    private var cookingProgress: some View {
        VStack(spacing:0) {
            Spacer()
            HStack(spacing:3) {
                let firstSlideId = recipe.wrappedIngredients.count > 0 ? 0 : 1
                let count = 1 + 1 + recipe.wrappedCookingSteps.count // ingrSlide( firstSlideId = 0/1 and OpenRange make balance) + FinalSlide + StepsCount
                
                
                ForEach(firstSlideId..<count, id: \.self) { i in
                    
                    Divider()
                        .padding(.vertical)
                        .frame(height: selection >= i ? 4: 2.0)
                        .onTapGesture {
                            withAnimation{
                                selection = i
                            }
                        }
                    
                        .frame(maxWidth:.infinity)
                        .background(
                            selection >= i ?
                            Color.accentColor : .secondary
                        )
                    
                }
            }
            .padding()
            
        }.background(Color.clear)
        
    }
    /**
     Sneak peek of the next step
     */
    private func getNextStepDirections(current:CookingStep) -> String? {
        guard let lastIndex = recipe.wrappedCookingSteps.ordered.last?.wrappedOrder, lastIndex >= (current.wrappedOrder+1) else {
            return nil
        }
        let step = recipe.wrappedCookingSteps.ordered[current.wrappedOrder+1]
        let text = step.wrappedDirections
        guard !(text.isEmpty) else {
            return nil
        }
        return text
    }
//FIXME: Crash on swipe
    
    private func speakStep(_ current: Int) {
        
        recognizer.stop()
        if current == 0, recipe.ingredients?.count ?? 0 > 0 { return } //do not speak aloud ingredients
        
        guard current <= recipe.cookingSteps?.count ?? 0, let direction = recipe.wrappedCookingSteps.ordered[current-1].directions else {
            return
        }
        speaker.speak(text: direction) {
            recognizer.start()
        }
    }
    private func speakerToggle() {
        speaker.setEnabled(!speaker.shouldSpeakUpStep)
    }
    private func speakerOn() {
        speaker.setEnabled(true)
    }
    private func speakerOff() {
        speaker.setEnabled(false)
    }
}

// MARK: - Previews

#Preview {
    CookingView(recipe: Recipe.firstForPreview())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    
}

