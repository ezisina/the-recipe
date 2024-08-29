//
//  TagsView.swift
//  TheRecipe
//
//  Created by Elena Zisina on 1/7/23.
//

import SwiftUI
import CoreData

struct TagsListView<Provider>: View where Provider: ObservableObject, Provider: TagProvider {
    @ObservedObject var provider: Provider

    var body: some View {
        ScrollView() {
            LazyVGrid(columns:[GridItem(.adaptive(minimum:65, maximum: 150), spacing: 2, alignment: .leading)], spacing: 2) {
                ForEach(Array(provider.wrappedTags), id: \.self) { value in
                    
                    TagInGridSmall(title: value.wrappedName)
                        
                }
            }
        }
    }
}



struct TagCloudView<Provider>: View where Provider: ObservableObject, Provider: TagProvider {
    @ObservedObject var provider: Provider

    @State private var totalHeight
        = CGFloat.infinity   // << variant for VStack

    private var wrappedTags: [Tag] {
        provider.wrappedTags.sorted { lhs, rhs in
            lhs.wrappedName < rhs.wrappedName
        }
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(maxHeight: totalHeight) // << variant for VStack
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(wrappedTags) { tag in
                TagInGridSmall(title: tag.wrappedName)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == wrappedTags.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == wrappedTags.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }

    

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

fileprivate struct TagInGridSmall : View {
    var title : String
    
    var body: some View {
        Text(hashString+titleStr)
//            .font(.footnote)
//            .italic()
//            .fontWeight(.semibold)
            .fixedSize(horizontal: true, vertical: true)
//            .padding(.horizontal, 8)
            .lineLimit(1)
            
            .padding(.vertical, 0)
//            .underlinedText()
            
    }
    private var titleStr : AttributedString {
        var attributedString = AttributedString("\(title)")
        
        attributedString.font = .footnote
        attributedString.underlineStyle = .patternDashDotDot
        
        return attributedString
    }
    private var hashString: AttributedString {
        let string = "#"
        var attributedString = AttributedString(string)
        
        attributedString.foregroundColor = .accentColor
        
        return attributedString
    }
}

#Preview {
        VStack {
            HStack(spacing: 10) {
                TagInGridSmall(title: "Dinner for dinner")
//                TagView(tag: "Lunch")
//                TagView(tag: "Абед")
            }
            TagsListView(provider: Recipe.firstForPreview())
            
            TagCloudView(provider: Recipe.firstForPreview())
        }
    
}
