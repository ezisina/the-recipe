//
//  ImportCocktailModel.swift
//  TheRecipe
//
//  Created by Elena Zisina on 6/12/23.
//

import Foundation
public struct InitModel : Codable {
    let version: String?
    let categories : [InitCategory]?
    let tags : [String]?
    let cocktails : [Cocktail]?
}
public struct InitCategory : Codable {
    let name : String
    let icon : String
}
public struct RecipesBackup : Codable {
    let recipes : [Recipe]?
}

struct Cocktail: Codable {
    
    let name : String
    let caption: String?
    
    let url : String?
    let drinkWare: String?
    let type : String?
    let preparationInstructions : String?
    let primaryAlcohol : [Alcohol]?
    let isIBA : Bool?
    let image : String?
    let servingType : String?
    let ingredients : [String]?
    let garnish : String?
   
}


enum ServingType: String, StringLocalizable {
    case straight = "straight"
    case unspecified = "unspecified"
    case neat = "neat"
    case rocks = "rocks"
    case chilled = "chilled"
    case blendedWIce = "blendedWIce"
    case hot = "hot"
    case straightrocks = "straightrocks"
    case layered = "layered"
    case chaser = "chaser"
    var localizedString: String {
        switch self {
        case .chaser:
            return "Chaser"
        case .layered:
            return "Layered"
        case .straightrocks:
            return "Straight or On the Rocks"
        case .hot:
            return "Hot"
        case .chilled:
            return "Chilled Glass"
        case .rocks:
            return "On the rocks, poured over ice cubes"
        case .neat:
            return "Neat, unmixed liquor"
        case .straight:
            return "Straight, without ice"
        case .unspecified:
            return "Doesn't matter"
        case .blendedWIce:
            return "Blended with crushed ice"
        }
    }
}



enum CocktailType: String, StringLocalizable {
    case cocktail = "cocktail"
    case unspecified = "unspecified"
    case mixed = "mixed"
    case wine = "wine"
    case beer = "beer"
    case layered = "layered"
    
    var localizedString: String {
        switch self {
        case .layered:
            return "Layered shooter"
        case .beer:
            return "Beer"
        case .cocktail:
            return "Cocktail"
        case .mixed:
            return "Mixed"
        case .wine:
            return "Wine"
        case .unspecified:
            return "Unspecified"
        
        }
        
    }
}



enum DrinkWare: String, StringLocalizable {
    case cocktailGlass = "cocktail"
    case unspecified = "unspecified"
    case pilsnerGlass = "pilsnerglass"
    case highball = "highball"
    case flute = "flute"
    case pint = "pintglass"
    case pint2 = "pint"
    case pubshot = "pubshot"
    case pintshot = "pintshot"
    case oldGlass = "old"
    case cachaça = "cachaça"
    case highballglassorrocksglass = "highballglassorrocksglass"
    case poco = "poco"
    case collins = "collins"
    case cup = "cup"
    case mug = "mug"
    case margarita = "margarita"
    case shot = "shot"
    case wine = "wine"
    case rocks = "rocks"
    case julep = "julep"
    var localizedString: String {
        switch self {
        case .shot:
            return "Shot Glass"
        case .pintshot:
            return "A Pint Glass and a Shot Glass"
        case .highballglassorrocksglass:
            return "Highball Glass or Rocks Glass"
        case .cachaça:
            return "Cachaça"
        case .cocktailGlass:
            return "Cocktail Glass"
        case .pilsnerGlass:
            return "Pilsner glass"
        case .highball:
            return "Highball glass"
        case .flute:
            return "Champagne flute"
        case .unspecified:
            return "Glass"
        case .pint, .pint2:
            return "Pint glass"
        case .pubshot:
            return "Pub shot"
        case .oldGlass:
            return "Old fashioned glass"
        case .poco:
            return "Hurricane glass"
        case .collins:
            return "Collins glass"
        case .cup:
            return "Cup"
        case .mug:
            return "Mug"
        case .margarita:
            return "Margarita Glass"
        case .wine:
            return "Wine Glass"
        case .rocks:
            return "Rocks Glass"
        case .julep: return "Julep stainless steel cup"
        }
    
    }
}



enum Alcohol: String, CaseIterable, StringLocalizable {
    case vermouth = "vermouth"
    case gin = "gin"
    case vodka = "vodka"
    case tequila = "tequila"
    case rum = "rum"
    case brandy = "brandy"
    case unspecified = "unspecified"
    case other = "other"
    case absinthe = "absinthe"
    case champagne = "champagne"
    case beer = "beer"
    case stout = "stout"
    case cognac = "cognac"
    case port = "port"
    case pisco = "pisco"
    case calvados = "calvados"
    case campari = "campari"
    case whiskey = "whiskey"
    case whisky = "whisky"
    case curaçao = "curaçao"
    case sake = "sake"
    case sambuca = "sambuca"
    
    var localizedString: String {
        switch self {
        case .sake:
            return "Sake"
        case .whiskey:
            return "Whiskey"
        case .whisky:
            return "Whisky"
        case .campari:
            return "Campari"
        case .vermouth:
            return "Vermouth"
        case .calvados:
            return "Calvados"
        case .pisco:
            return "Pisco"
        case .port:
            return "Port wine"
        case .gin:
            return "Gin"
        case .vodka:
            return "Vodka"
        case .unspecified:
            return "Unspecified"
        case .tequila:
            return "Tequila"
        case .rum:
            return "Rum"
        case .brandy :
            return "Brandy"
        case .absinthe :
            return "Absinthe"
        case .champagne :
            return "Champagne"
        case .other:
            return "Something"
        case .beer:
            return "Beer"
        case .stout:
            return "Stout, beer"
        case .cognac:
            return "Cognac"
        case .curaçao:
            return "Blue Curaçao"
        case .sambuca:
            return "Sambuca"
        }
    
    }
}


protocol StringLocalizable : Codable {
    var localizedString: String { get }
}
