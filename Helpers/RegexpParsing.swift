//
//  RegexpParsing.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 05/12/2023.
//

import Foundation

fileprivate func extractedFunc(_ match: NSTextCheckingResult, _ lineRange: NSRange, _ input: String, _ actions: inout [String]) {
    for rangeIndex in 0..<match.numberOfRanges {
        let matchRange = match.range(at: rangeIndex)
        
        // Ignore matching the entire username string
        if matchRange == lineRange { continue }
        
        // Extract the substring matching the capture group
        if let substringRange = Range(matchRange, in: input) {
            let capture = String(input[substringRange])
            actions.append(capture)
        }
    }
}

func parseRegexp<T>(_ input: String,
                    capturePattern: String,
                    getAllMatches: Bool = false,
                    processGroups: (([String]) throws -> T)) throws -> T {
    let captureRegex = try! NSRegularExpression(pattern: capturePattern, options: [])
    let lineRange = NSRange(input.startIndex..<input.endIndex, in: input)
    let matches = captureRegex.matches(in: input, options: [], range: lineRange)
    guard let match = matches.first else {
        throw AoCError.wrongFormat
    }
    var actions: [String] = []
    if getAllMatches {
        matches.forEach { extractedFunc($0, lineRange, input, &actions) }
    } else {
        extractedFunc(match, lineRange, input, &actions)
    }
    return try processGroups(actions)
}
