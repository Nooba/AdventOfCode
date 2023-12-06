//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

private struct AlmanacMap {
    
    struct Range {
        let start: Int
        let length: Int
        let destination: Int

        func convert(source: Int) -> Int {
            return destination + source - start
        }

        func contains(item: Int) -> Bool {
            return (start...start+length).contains(item)
        }
    }

    let ranges: [Range]

    init(seed: [String]) throws {
        let rangeSeeds = Array(seed[1..<seed.count])
        ranges = try rangeSeeds.map { rangeSeed in
            let components = rangeSeed.components(separatedBy: CharacterSet.whitespaces).compactMap { Int($0) }
            guard components.count == 3 else { throw AoCError.wrongFormat }
            return Range(start: components[1], length: components[2], destination: components[0])
        }
    }

    func convert(item: Int) throws -> Int {
        guard let foundRange = (ranges.first { range in
            range.contains(item: item)
        }) else { return item }
        return foundRange.convert(source: item)
    }
}

func day5_2023_A() throws -> Int {
    var groupedLines = try FileReader(filename: "day5_2023_input").getGroupedLines()
    let seeds = groupedLines[0].first!.components(separatedBy: CharacterSet.whitespaces).compactMap { Int($0) }
    groupedLines = Array(groupedLines[1..<groupedLines.count])
    var currentValues = seeds
    try groupedLines.forEach { almanacSeed in
        let currentAlmanacMap = try AlmanacMap(seed: almanacSeed)
        currentValues = try currentValues.map { try currentAlmanacMap.convert(item: $0) }
//        print(currentValues)
    }
    return currentValues.min()!
}

private func parseLineSecondPart(_ line: String) throws -> Int {
    return -1
}

func day5_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day5_2023_example").getLines()
    let numbers = try lines.map(parseLineSecondPart(_:))
    return numbers.reduce(0, +)
}
