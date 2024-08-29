//
//  BinaryInteger+Time.swift
//  TheRecipe
//

import Foundation

extension Double {
    /// The seconds calculated from the total seconds value contained in the value.
    var seconds: Int {
        get { Int(self) % 60 }
        set { self = seconds(fromHours: hours, minutes: minutes, seconds: newValue) }
    }
    
    /// The minutes calculated from the total seconds value contained in the value.
    var minutes: Int {
        get { (Int(self) % 3_600) / 60 }
        set { self = seconds(fromHours: hours, minutes: newValue, seconds: seconds) }
    }
    
    /// The hours calculated from the total seconds value contained in the value.
    var hours: Int {
        get { Int(self) / 3_600 }
        set { self = seconds(fromHours: newValue, minutes: minutes, seconds: seconds) }
    }
    
    /// Returns a human readable string composed of time components.
    ///
    /// String format is (depending on localization):
    ///     XX h XX min XX sec
    ///
    /// Each component can be omitted if equals to zero.
    var humanReadableTime: String {
        let h = hours
        let m = minutes
        let s = seconds
        return [
            h > 0 ? NSLocalizedString("\(h) h", comment: "Time string representing hours") : nil,
            m > 0 ? NSLocalizedString("\(m) min", comment: "Time string representing minutes") : nil,
            s > 0 ? NSLocalizedString("\(s) sec", comment: "Time string representing seconds") : nil
        ]
            .compactMap { $0 }
            .joined(separator: " ")
    }
    
    /// Returns a human readable string composed of time components.
    /// Used in the TimerView
    /// String format is:
    ///     XX : XX : XX
    ///
    /// Each component can be omitted if equals to zero.
    var humanReadableTimeTimerLook: String {
        let h = hours
        let m = minutes
        let s = seconds
        return [
            h > 0 ? String(format: "%02d", h) : nil,
            m > 0 || h > 0 ? String(format: "%02d", m) : "00",
            h == 0 ? String(format: "%02d", s) : nil
        ]
            .compactMap { $0 }
            .joined(separator: " : ")
    }
    
    
    /// Converts given components into a seconds value, suitable for storage.
    ///
    /// - Parameters:
    ///   - hours:   Amount of hours.
    ///   - minutes: Amount of minutes.
    ///   - seconds: Amount of seconds.
    ///
    /// - Returns: Given time interval represented in seconds.
    private func seconds(fromHours hours: Int, minutes: Int, seconds: Int) -> Self {
        Self(hours * 3_600 + minutes * 60 + seconds)
    }
}
