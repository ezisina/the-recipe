//
//  TagsAutocompleter.swift
//  TheRecipe
//
//  Created by Elena Zisina on 8/31/23.
//

import SwiftUI
import CoreData

struct TagsAutocompleterView<Provider>: View where Provider: ObservableObject, Provider: TagProvider {
    @State private var tagText : String  = ""
    @State private var popupTagPresented : Bool =  false
    @ObservedObject var provider: Provider
    
    @FetchRequest(sortDescriptors: [ SortDescriptor(\Tag.name, order: .forward) ], predicate: NSPredicate(value: true), animation: .default)
    private var tags: FetchedResults<Tag>
    
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        VStack(spacing: 0) {
            TextField("+Tags", text: $tagText)
                .onChange(of: tagText, perform: { newTag in
                    //Delay tag filter to trigger better combination
                    Task { @MainActor in
                        
                        try await Task.sleep(for: .seconds(0.5))
                        
                        if !(newTag.isEmpty) {
                            popupTagPresented = true
                        }
                        let filteredMatches = tags.filter{$0.wrappedName.contains(tagText)}
                            .filter{!(provider.wrappedTags.contains($0))}
                        if filteredMatches.isEmpty {
                            popupTagPresented = false
                        }
                    }
                    
                })
                .onSubmit {
                    processTag(tagText)
                }
                .popover(isPresented: $popupTagPresented) {
                    let filteredMatches = tags.filter{$0.wrappedName.contains(tagText)}
                        .filter{!(provider.wrappedTags.contains($0))}
                    VStack {
                        
                        HStack {
                            Text("Found tags...")
                            Spacer()
                        }
                        .sheetTitleStyle()
                        .padding(.bottom, 15)
                        ScrollView {
                            LazyVGrid(columns:[GridItem(.adaptive(minimum:100, maximum: 250), spacing: 5, alignment: .leading)], spacing: 5) {
                                ForEach(filteredMatches) { suggestion in
                                    Button {
                                        tagText = suggestion.wrappedName
                                        processTag(suggestion)
                                        popupTagPresented = false
                                    } label: {
                                        Text(suggestion.wrappedName )
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineLimit(2)
                                    }
                                    .buttonStyle(.bordered)
                                    
                                }
                            }
                        }
                        .padding()
                    }
                    //if #available(iOS 16, *) {
                    //  .presentationCompactAdaptation(.none)
                    //} else {
                    .presentationDetents([.medium])
                    //}
                }
        }
    }
    
    
    func processTag(_ tag : Tag) {
        provider.addToTags(tag)
        tagText = ""
    }
    
    func processTag(_ tagText : String) {
        let tagTextTrimmed = tagText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let tag = Tag.findOrNew(tagTextTrimmed, by: \.name, inContext: viewContext)
        tag.name = tagTextTrimmed
        
        tag.managedObjectContext?.saveChanges()
        
        processTag(tag)
    }
}

#Preview {
    TagsAutocompleterView(provider: Recipe.firstForPreview())
}
