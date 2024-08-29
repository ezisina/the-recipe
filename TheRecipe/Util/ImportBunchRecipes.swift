//
//  ImportCocktails.swift
//  TheRecipe
//
//  Created by Elena Zisina on 6/12/23.
//

import Foundation
import CoreData

func emptyDB(with context: NSManagedObjectContext) {
//    deletePhotos()

    let fetchRequestIngredient: NSFetchRequest<NSFetchRequestResult>
    fetchRequestIngredient = NSFetchRequest(entityName: "Ingredient")
    deleteTable(with: context, and: fetchRequestIngredient)
    
    let fetchRequestRecipe: NSFetchRequest<NSFetchRequestResult>
    fetchRequestRecipe = NSFetchRequest(entityName: "Recipe")
    deleteTable(with: context, and: fetchRequestRecipe)
    
    let fetchRequestDinnerMenu: NSFetchRequest<NSFetchRequestResult>
    fetchRequestDinnerMenu = NSFetchRequest(entityName: "DinnerMenu")
    deleteTable(with: context, and: fetchRequestDinnerMenu)

    let fetchRequestTag: NSFetchRequest<NSFetchRequestResult>
    fetchRequestTag = NSFetchRequest(entityName: "Tag")
    deleteTable(with: context, and: fetchRequestTag)
    
    context.saveChanges()
}
func deleteTable(with context: NSManagedObjectContext, and fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
    
    // Specify a batch to delete with a fetchRequest

    // Create a batch delete request for the
    // fetch request
    let deleteRequest = NSBatchDeleteRequest(
        fetchRequest: fetchRequest
    )

    // Specify the result of the NSBatchDeleteRequest
    // should be the NSManagedObject IDs for the
    // deleted objects
    deleteRequest.resultType = .resultTypeObjectIDs

    // Get a reference to a managed object context
   // let context = persistentContainer.viewContext

    // Perform the batch delete
    let batchDelete = try? context.execute(deleteRequest)
        as? NSBatchDeleteResult

    guard let deleteResult = batchDelete?.result
        as? [NSManagedObjectID]
        else { return }

    let deletedObjects: [AnyHashable: Any] = [
        NSDeletedObjectsKey: deleteResult
    ]

    // Merge the delete changes into the managed
    // object context
    NSManagedObjectContext.mergeChanges(
        fromRemoteContextSave: deletedObjects,
        into: [context]
    )
    
}

//FIXME: add async and combine
func loadRecipes(url:String? = nil, with context: NSManagedObjectContext) {
    getJson(url: url, with :context)
}

fileprivate func getJson(url:String? = nil, with context: NSManagedObjectContext) {
    var filename = url
    var fileURL : URL?
    if  filename == nil {
        //open from bundle
#if DEBUG
         filename = "testDatasetCocktails.json"
        //testDatasetCocktails
#else
         filename = "datasetCocktails.json"
        //datasetCocktails
#endif
        
        // we found the file in our bundle!
        guard let url = filename,  let  initData : InitModel = Bundle.main.decode(url) else {
                // we loaded the file into a string!
            print("\(String(describing: filename)) with empty content")
            return
        }
        parseJson(data: initData, with: context)
    } else {
         fileURL = URL(string: filename!)
        //TODO: decode from file from url
    }



    return
        
    }

fileprivate func parseJson(data: InitModel, with context: NSManagedObjectContext) {
//print(json)
    switch data.version {
        case  "cocktails":
        parseCocktails(data.cocktails, with: context)
        default:
            return
    }
   // let  initData : InitModel = json.decode("initDatatest.json")
}

fileprivate func parseCocktails(_ data: [Cocktail]?, with context: NSManagedObjectContext) {
    guard let data = data else {return}

    let db = context//NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//    db.parent = context
    var alcats:[Alcohol: Tag] = [:]
    Alcohol.allCases.forEach { cat in
        alcats[cat] = Tag.findOrNew(cat.localizedString.lowercased(), by: \.name, inContext: db)
    }
    let tagIBA = Tag.findOrNew("iba", by: \.name, inContext: db)
    
    let tagCocktail = Tag.findOrNew("cocktail", by: \.name, inContext: db)
   
    let tagRecipe = Tag.findOrNew("recipe", by: \.name, inContext: db)
    data.forEach {content in
        if !(content.url?.isEmpty ?? true) {
            let fetchReqRecipe: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Recipe")
            fetchReqRecipe.predicate = NSPredicate(format: "source == %@", "https://en.wikipedia.org/wiki/\(content.url!)" as CVarArg)
            fetchReqRecipe.fetchLimit = 1
            if let rr = (try? db.fetch(fetchReqRecipe)) , !rr.isEmpty {
                return
            }
        }
        
        let recipe = Recipe(context: db)
        recipe.title = content.name
        recipe.summary = content.caption
        
        if !(content.url?.isEmpty ?? true) {
            recipe.source = "https://en.wikipedia.org/wiki/\(content.url!)"
        }
        //Tags
        recipe.addToTags(tagCocktail)
        recipe.addToTags(tagRecipe)
        
        if let alcoCats = content.primaryAlcohol?.map({ alcats[$0] }) {
            recipe.addToTags(Set(alcoCats) as NSSet)
        }
        if content.isIBA ?? false {
            recipe.addToTags(tagIBA)
        }
        recipe.comment = """
Garnish with \(content.garnish ?? "something");
Serving \(ServingType(rawValue: content.servingType ?? "unspecified")?.localizedString ?? ServingType.unspecified.localizedString) in the \(DrinkWare(rawValue: content.drinkWare ?? "unspecified")?.localizedString ?? DrinkWare.unspecified.localizedString)
"""
        
        //Image
        //FIXME: test it
         if !(content.image?.isEmpty ?? true) {
             recipe.addImage(url:"https://commons.wikimedia.org/w/index.php?title=Special:Redirect/file/\(content.image!)&width=600",
                             licenseUrl : "https://en.wikipedia.org/wiki/File:\(content.image!)")
         }
         
        //CookingSteps
        if !(content.preparationInstructions?.isEmpty ?? true) {
            let llines = content.preparationInstructions!.lines
            for (index, line) in llines.enumerated() {
                let step = recipe.addCookingStep()
                step.directions = line
                step.order = Int16(index)

            }
            
        }
        //Ingredients
        if (content.ingredients?.count ?? 0) > 0 {
            content.ingredients!
                .filter { !$0.isEmpty }
                .enumerated()
                .forEach {//FIXME: make an extension from it  or something
                    let sentence = $0.element.trimmingCharacters(in: .whitespacesAndNewlines)
                    let splits = sentence.split(separator: " ", maxSplits:2, omittingEmptySubsequences: true)
                    
                    guard splits.count > 1 else { return }
                    let amount = String(splits[0]) //Double
                    let ingredientamount = amount.numberWFractionsToDouble()
                    
                    
                    let measureUnit = String(splits[1]).lowercased()
                    let ingredientwrappedUnit = measureUnit.getUnit().unit
                    
                    let koeff = measureUnit.getUnit().koeff
                    var name = ""
                    if ingredientwrappedUnit == nil, splits.count == 2 {
                        name = measureUnit
                    } else {
                        name = String(splits[2])
                    }
                    var comment : String?
                    if name.contains("(") {
                        let startComment = name.firstIndex(of: "(")!
                        let endComment = name.firstIndex(of: ")")!
                        comment = String(name[startComment..<endComment].dropFirst())
                        name.removeSubrange(startComment...endComment)
                        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    let ing = Ingredient.findOrNew(name, by: \.name ,inContext: db)
                    
                    let ingredient = recipe.addIngredient(ing, amount: ingredientamount*koeff, unit: ingredientwrappedUnit)
                    ingredient.comment = comment

                }
           
        }
        
    }
    db.saveChanges()
    db.parent?.saveChanges()
}
