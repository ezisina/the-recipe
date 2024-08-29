//
//  Utils.swift
//  TheRecipe
//
//  Created by Elena Zisina on 5/22/23.
//

import Foundation

extension StringProtocol {
    var lines: [String] { split(whereSeparator: \.isNewline).map({String($0)}) }
}
//FIXME: write test on 1, 1/2, ½, 1 1/2
extension String {
    ///Convert franction symbols to Double
    private func fractionToDouble() -> Double {
        switch self {
        case "½": return 0.5    // 1/2
        case "1/2": return 0.5
        case "¼": return 0.25   // 1/4
        case "1/4" : return 0.25
        case "¾" : return 0.75  // 3/4
        case "3/4" : return 0.75
        case "⅓": return 0.33   // 1/3
        case "1/3": return 0.33
        case "⅔" : return 0.66  // 2/3
        case "2/3" : return 0.66
        case "⅛" : return 0.125 // 1/8
        case "1/8" : return 0.125
        default:
            return 0.0
        }
    }
    
    func numberWFractionsToDouble() -> Double {

        var result = 0.0
        if self.contains("/") {
            //Fractions here
            result = String(self).fractionToDouble()
            return result
        }
        for part in self {
            let a = (Double(String(part)) ?? 0.0)
            if a > 0 {
                result += a
            } else {
                result += String(part).fractionToDouble()
            }
        }
        return result

    }
    
    
    ///Convert text to Apple's Measure Unit
    func getUnit() -> (unit:Unit?, koeff:Double) {

        switch self {
        case "teaspoon","teaspoons", "tsp":
            return (UnitVolume.teaspoons, 1)
        case "barspoon":
            return (UnitVolume.teaspoons, 0.5)
        case "dash", "dashes", "pinch", "pinches":
            return (UnitVolume.teaspoons, 0.125)
        case "tablespoon", "tablespoons", "tbsp":
            return (UnitVolume.tablespoons, 1)
        case "cup", "cups":
            return (UnitVolume.cups, 1)
        case "oz", "oz.", "part", "parts", "ounces":
            return (UnitVolume.fluidOunces, 1)
        case "g", "gms":
            return (UnitMass.grams, 1)
        case "kg", "kgs":
            return (UnitMass.kilograms,1)
        case "cl", "cL":
            return (UnitVolume.milliliters, 10)
        default:
            return (nil, 1)
            
        }

    }
}
