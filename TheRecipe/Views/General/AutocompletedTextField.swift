//
//  AutocompletedTextField.swift
//  TheRecipe
//
//  Created by Elena Zisina on 9/13/23.
//
//TODO: add styling to be able to override
//https://gist.github.com/sanzaru/6dcfb850a67b3377238f68e8a2ba67b1#file-progress-view-complete-swift
import SwiftUI

struct AutocompletedTextField<T, Item>: View where Item: View, T: Hashable {
    var titleKey: LocalizedStringKey
    @Binding var selection: AutocompleteSelection<T>
    var fetch: (String) -> [T]?
    @ViewBuilder var item: (T) -> AutocompleterItem<Item>
    @EnvironmentObject private var vm: ViewModel
    @State private var frame = CGRect.zero
    
    var body: some View {
        
        TextField(titleKey, text: $vm.autocompleterText)
            .autocorrectionDisabled()
            .overlay {
                GeometryReader { gm in
                    Color.clear
                        .onAppear {
                            frame = gm.frame(in: .global)
                        }
                        .onChange(of: gm.size) { _ in
                            frame = gm.frame(in: .global)
                    }
                }
            }
            .onChange(of: vm.autocompleterText) { text in
                guard vm.autocompleterText.isEmpty || vm.autocompleterText != vm.lastAutocompletedText else {
                    return
                }
                //vm.showList(of: fetch(text), selection: $selection, inFrame: frame, with: item)
            }
            .overlay(alignment: .trailing) {
                Button(role: .cancel, action: {vm.autocompleterText = ""}) {
                    Label("Clear", systemImage:"xmark.circle" )
                        .labelStyle(.iconOnly)
                }
                .hidden(when: vm.autocompleterText.isEmpty )
                .buttonStyle(ClearButtonStyle())
            }
           // .overlay(alignment: .bottom) {
        //https://github.com/dmytro-anokhin/Autocomplete?ref=iosexample.com
                List(fetch(vm.autocompleterText) ?? Array(), id: \.self) { item in
                    ZStack {
                        // let listItem = builder(item)
                        Button {
                            //                        selection.wrappedValue = .item(item)
                            //                        self.autocompleterText = listItem.autocompletedText
                            //                        self.lastAutocompletedText = listItem.autocompletedText
                            //                        self.autocompleterView = AnyView(EmptyView())
                            //                        self.autocompleterFrame = .zero
                        } label: {
                            // listItem
                            Text("item")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    
                }
               // .background(.red)
                .offset(y:-50)
          //  }
            
    }

}


struct AutocompleterWrapper<Content>: View where Content: View {
    var maxHeight: CGFloat
    @ViewBuilder var content: Content
    @StateObject private var vm = ViewModel()
    
    var body: some View {
        ZStack {
            content
                .environmentObject(vm)

            Color.clear
                .overlay {
                    GeometryReader { gm in
                        positionAutocompletion(inside: gm.frame(in: .global))
                    }
                }
                
        }
    }
    
    /* TODO: complete styling
    func applyStyle<Style>(_ style: Style) -> some View where Style: AutocompleterStyle {
        let config = AutocompleterStyleConfiguration(autocompleter: self.body as! AutocompleterStyleConfiguration.Content)
        return style.makeBody(config)
    }
    */
    private func positionAutocompletion(inside frame: CGRect) -> some View {
        let contentHeight = min(vm.contentSize.height, maxHeight)
        
        let dx = vm.autocompleterFrame.midX - frame.midX - vm.autocompleterFrame.width/2
        let dy = vm.autocompleterFrame.midY - frame.midY - contentHeight/2
        
        let frameMidX = frame.midX - frame.minX
        let frameMidY = frame.midY - frame.minY

                
        var offset = vm.autocompleterFrame.height + contentHeight
        if frameMidY + dy + offset > frame.height {
            offset *= -1
        }
        print("autocompleter list frame ", frame, vm.autocompleterFrame)
        return vm.autocompleterView
            .frame(width: vm.autocompleterFrame.width, height: contentHeight)
            .offset(x: frameMidX + dx, y: frameMidY + dy + offset/2)
    }
    /*
    func autocompleterStyle(_ style: some AutocompleterStyle) -> some View {
        let config = AutocompleterStyleConfiguration(autocompleter: self)
        return style.makeBody(config)
            
    }
     */
}

fileprivate class ViewModel: ObservableObject {
    @Published var autocompleterText = ""
    @Published private(set) var lastAutocompletedText = ""
    @Published private(set) var autocompleterFrame = CGRect.zero
    @Published private(set) var contentSize = CGSize.zero
    @Published private(set) var autocompleterView = AnyView( EmptyView() )

    func showList<T, Item>(of items: [T]?, selection: Binding<AutocompleteSelection<T>>, inFrame frame: CGRect, with builder: @escaping (T) -> AutocompleterItem<Item>) where Item: View {
        print("call for showlist")
        lastAutocompletedText = ""
        autocompleterFrame = frame
        if autocompleterText.isEmpty {
            selection.wrappedValue = .none
        }
        if !autocompleterText.isEmpty {
            selection.wrappedValue = .plainText(autocompleterText)
        }
        guard let items = items else {
            autocompleterView = AnyView(EmptyView())
            return
        }
        print("show list ", items.count)
        autocompleterView = AnyView(
            List(items, id: \.self) { item in
                    ZStack {
                        let listItem = builder(item)
                        Button {
                            selection.wrappedValue = .item(item)
                            self.autocompleterText = listItem.autocompletedText
                            self.lastAutocompletedText = listItem.autocompletedText
                            self.autocompleterView = AnyView(EmptyView())
                            self.autocompleterFrame = .zero
                        } label: {
                            listItem
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    
                }
//            ScrollView {
//                VStack {
//                    ForEach(items, id: \.self) { [weak self] item in
//                        let listItem = builder(item)
//                        Button {
//                            selection.wrappedValue = .item(item)
//                            self?.autocompleterText = listItem.autocompletedText
//                            self?.lastAutocompletedText = listItem.autocompletedText
//                            self?.autocompleterView = AnyView(EmptyView())
//                            self?.autocompleterFrame = .zero
//                        } label: {
//                            listItem
//                        }
//                        
//                        .frame(maxWidth: .infinity)
//                        .padding(4)
//                    }
//                }
//                .overlay {
//                    GeometryReader { gm in
//                        Color.clear
//                            .onAppear { [weak self] in
//                                self?.contentSize = gm.size
//                            }
//                            .onChange(of: gm.size) { [weak self] _ in
//                                print("got size \(gm.size)")
//                                self?.contentSize = gm.size
//                            }
//                    }
//                }
//            }
//            .background {
//                Color.accentColor
//                    .opacity(0.2)
//                    .shadow(radius: 5)
//                    
//            }
//            .buttonStyle(AutocomleteListItemStyle())
            
        )
        
    }
}
/* TODO: complete styling
struct AutocompleterStyleConfiguration {
//    struct Content: View {
//        var body: Never
//        
//        typealias Body = Never
//    }
//    
//    var autocompleter: Self.Content
    
    init(_ autocompleter: AutocompleterWrapper<some View>) {
        self.autocompleter = Content(body: )
    }
}

protocol AutocompleterStyle {
    associatedtype Content: View
    typealias Configuration = AutocompleterStyleConfiguration
    
    @ViewBuilder func makeBody(_ configuration: Self.Configuration) -> Self.Content
}

struct MyAutocompleterStyle: AutocompleterStyle {
//    @ViewBuilder func makeBody(_ configuration: Self.Configuration) -> some View {
//        configuration.autocompleter
//            .background(Color.red)
//    }
    func makeBody(_ configuration: Configuration) -> some View {
        Text("??")
    }
}

struct StyleModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        let config = AutocompleterStyleConfiguration(autocompleter: content)
    }
}

 */
extension View {
    func enableAutocompleterFields(maxHeight: CGFloat = 200) -> AutocompleterWrapper<some View> {
        AutocompleterWrapper(maxHeight: maxHeight) {
            self
        }
    }
}


struct AutocompleterItem<Content>: View where Content: View {
    var autocompletedText: String
    var content: () -> Content
    
    var body: some View {
        content()
    }
}

struct AutocompletedTextField_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }
    private struct Preview: View {
        @State private var selection: AutocompleteSelection<String> = .none
        var body: some View {
            AutocompletedTextField(titleKey: "Test", selection: $selection) { text in
                [
                    "one",
                    "two",
                    text
                ]
            } item: { text in
                AutocompleterItem(autocompletedText: text) {
                    Text(text)
                }
            }
        }
    }
}

fileprivate struct AutocomleteListItemStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor)
            .font(Font.body.bold())
            .frame(maxWidth: .infinity)
            .padding(padding)
            .background(Color.accentColor.opacity(
                configuration.isPressed ? pressedColorOpacity : 0
                        ))
    }
}

fileprivate struct ClearButtonStyle : ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            //.tint(tint)
            .foregroundColor(tintColor)
    }
}

extension ButtonStyle {
    var foregroundColor: Color { .primary }
    var padding: CGFloat { 0 }
    var pressedColorOpacity: Double { 1 }
}
//FIXME:
extension ScrollView {
    var svBackground : some View {
        Color.accentColor
            .opacity(0.2)
            .shadow(radius: 5)
    }
}

extension ButtonStyle {
    var tintColor: Color { .secondary }

}
