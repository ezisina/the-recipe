//
//  Units.swift
//  TheRecipe
//

import Foundation

/// Cooking units supported by the application.
struct Units {
    
    /// List of the supported units, prioritized based on user's locale.
    static let list: [Unit] = {
        if Locale.current.measurementSystem == Locale.MeasurementSystem.metric {
            return metric + imperial + pieces
        } else {
            return imperial + metric + pieces
        }
    }()
    
    private static let pieces: [Unit] = [
        Unit(symbol: "pcs") // Pieces - quantificational unit
    ]
    
    /// Supported Imperial units.
    private static let imperial: [Unit] = [
        UnitVolume.cups,
        UnitVolume.teaspoons,
        UnitVolume.tablespoons,
        UnitVolume.fluidOunces,
        UnitMass.pounds,
        UnitMass.ounces
    ]
    
    /// Supported Metric units.
    private static let metric: [Unit] = [
        UnitMass.kilograms,
        UnitMass.grams,
        UnitMass.milligrams,
        UnitVolume.milliliters,
        UnitVolume.liters,
        UnitVolume.deciliters
    ]
}


extension Unit: Identifiable {
    public var id: String {
        self.symbol
    }
}
