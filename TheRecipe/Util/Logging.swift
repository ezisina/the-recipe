//
//  Logging.swift
//  The Recipe
//

import Foundation
import OSLog

/// A very primitive wrapper around `Logger`.
///
/// Returns `Logger` struct initialized with subsystem equal to the main bundle identifier and
/// category showing the object, method, and the line the log initiated from.
///
/// - Parameters:
///   - file:       Name of the file from which the function was called. Should not be specified manually.
///   - function:   Name of the method  that called the function. Should not be specified manually.
///   - line:       Line number in the `file` that contains the call to the function. Should not be specified manually.
///   
/// - Returns: `Logger` instance which handles the actual logging with the given severity.
func Log(file: String = #fileID, function: String = #function, line: UInt = #line) -> Logger {
    var slashIdx: String.Index?
    if let idx = file.lastIndex(of: "/") {
        slashIdx = file.index(after: idx)
    }
    let filename = file.suffix(from: slashIdx ?? file.startIndex)
    let className = filename.prefix(upTo: filename.lastIndex(of: ".") ?? filename.endIndex)
    let methodName = function.prefix(upTo: function.firstIndex(of: "(") ?? function.endIndex)
    
    return Logger(subsystem: "global", category: "\(className).\(methodName):\(line)")
}

