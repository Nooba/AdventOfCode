//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

private struct Box {
    let sizes: [Int]

    var neededPaper: Int {
        let wrapping = (2*sizes[0]*sizes[1]) + (2*sizes[1]*sizes[2]) + (2*sizes[0]*sizes[2])
        let offset = sizes.sorted().prefix(2).reduce(1, *)
        return wrapping + offset
    }

    var neededRibbon: Int {
        let wrapping = sizes.sorted().prefix(2).reduce(0, +)*2
        let offset = sizes[0]*sizes[1]*sizes[2]
        return wrapping+offset
    }
}

private func parseLine(_ line: String) throws -> Box {
    let capturePattern = #"(\d+)x(\d+)x(\d+)"#
    let captureRegex = try! NSRegularExpression(
        pattern: capturePattern,
        options: []
    )
    let lineRange = NSRange(line.startIndex..<line.endIndex, in: line)
    let matches = captureRegex.matches(in: line, options: [], range: lineRange)
    guard let match = matches.first else {
        throw AoCError.wrongFormat
    }
    var actions: [String] = []
    for rangeIndex in 0..<match.numberOfRanges {
        let matchRange = match.range(at: rangeIndex)

        // Ignore matching the entire username string
        if matchRange == lineRange { continue }

        // Extract the substring matching the capture group
        if let substringRange = Range(matchRange, in: line) {
            let capture = String(line[substringRange])
            actions.append(capture)
        }
    }
    return Box(sizes: actions.map { Int($0)! } )
}



func day2_2015_A() throws -> Int {
    let lines = try FileReader(filename: "day2_2015_input").getLines()
    let boxes = try lines.map(parseLine(_:))
    return boxes.map { $0.neededPaper }.reduce(0, +)
}

func day2_2015_B() throws -> Int {
    let lines = try FileReader(filename: "day2_2015_input").getLines()
    let boxes = try lines.map(parseLine(_:))
    return boxes.map { $0.neededRibbon }.reduce(0, +)
}
