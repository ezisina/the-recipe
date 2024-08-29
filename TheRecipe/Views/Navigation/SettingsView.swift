//
//  SettingsView.swift
//  TheRecipe
//
//  Created by Elena Zisina on 6/7/23.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var showConfirmationOnDelete = false
    @EnvironmentObject private var appState:AppState
    @State private var showingProgress = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ScrollView {
                        AboutView()
#if DEBUG
                        VStack {
                            //FIXME: add responce Alert("Added n recipes") on success
                            LabeledContent {
                                Button("Load Cocktails", systemImage: "square.and.arrow.down") {
                                    Task{
                                        showingProgress = true
                                        let context = NSManagedObjectContext(.mainQueue)
                                        context.parent = viewContext
                                        loadRecipes(with: context)
                                        UserDefaults.standard.set(true, forKey: "CoctailsDownloaded")
                                        try? await Task.sleep(for: .seconds(2))
                                        showingProgress = false
                                    }
                                }.foregroundColor(.accentColor)
                                    .labelStyle(.iconOnly)
                                
                            } label: {
                                Text("Download Cocktails pack")
                                    .sectionHeaderStyle()
                                Text("Wikipedia.org")
                                    .noteStyle()
                            }
                            //                        .disabled(UserDefaults.standard.bool( forKey: "CoctailsDownloaded"))
                            //TODO: use fileExporter() for export
                            //https://www.hackingwithswift.com/quick-start/swiftui/how-to-export-files-using-fileexporter
                            LabeledContent {
                                Button("Export recipes", systemImage: "square.and.arrow.up") {
                                    showingExporter = true
                                }.foregroundColor(.accentColor)
                                    .labelStyle(.iconOnly)
                                
                            } label: {
                                Text("Export the dump")
                                    .sectionHeaderStyle()
                            }
                            
                            LabeledContent {
                                Button("Import recipes", systemImage: "square.and.arrow.down") {
                                    showingImporter = true
                                }.foregroundColor(.accentColor)
                                    .labelStyle(.iconOnly)
                                
                            } label: {
                                Text("Import the dump")
                                    .sectionHeaderStyle()
                            }
#if DEBUG
                            Divider()
                            Toggle("Recipes Only",
                                   systemImage: "fork.knife",
                                   isOn: $appState.recipesOnlyModeIsON
                            )
                            LabeledContent {
                                Button("Empty DB", systemImage: "folder.fill.badge.minus", role: .destructive) {
                                    showConfirmationOnDelete = true
                                    
                                }.foregroundColor(.accentColor)
                                    .labelStyle(.iconOnly)
                                    .alert(Text("Are you sure?", comment: "Recipe deletion confirmation alert title"), isPresented: $showConfirmationOnDelete) {
                                        Button("Delete", role: .destructive)  {
                                            UserDefaults.standard.set(false, forKey: "CoctailsDownloaded");
                                            emptyDB(with: viewContext)
                                            
                                            appState.resetState()
                                        }
                                    }
                            } label: {
                                Text("Empty DB")
                                    .sectionHeaderStyle()
                            }
#endif
                            //.disabled(UserDefaults.standard.bool( forKey: "EnableExport"))
                        }.padding()
                        
#endif
                    }
                    CopyrightView()
                        .padding()
                }
                if (showingProgress) {
                    
                    ProgressView().tint(.accentColor)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
#if !os(macOS)
            .navigationBarTitleDisplayMode(.large)
            //            .toolbarRole(.navigationStack)
#else
            .frame(minWidth:400, minHeight: 400)
#endif
            .navigationTitle("Welcome to TheRecipe")
            .toolbar{
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") {dismiss()}
                        .labelStyle(.titleAndIcon)
                        .foregroundColor(.accentColor)
                }
            }
            .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.json], allowsMultipleSelection: false) { res in
                do{
                    guard let fileUrl = try res.get().first else {
                        return
                    }
                    let _ = fileUrl.startAccessingSecurityScopedResource()
                    let data = try Data(contentsOf: fileUrl)
                    viewContext.import(from: data)
                } catch {
                    print ("error reading")
                    debugPrint(error)
                }
            }
            .fileExporter(
                isPresented: $showingExporter,
                document: JsonDocument(data: viewContext.export() ?? Data()),
                contentType: .json,
                defaultFilename: "TheRecipe.txt") { result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    fileprivate func loadCocktailRecipes() {
        UserDefaults.standard.set(true, forKey: "CoctailsDownloaded")
        loadRecipes(with: viewContext)
    }
    
    //FIXME: Add recipesOnlyModeIsON to UserDefaults
}

#Preview {
    SettingsView()
}

