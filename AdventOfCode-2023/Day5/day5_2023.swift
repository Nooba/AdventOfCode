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
            return (start..<start+length).contains(item)
        }
    }

    let ranges: [Range]

    init(seed: [String]) throws {
        let rangeSeeds = Array(seed[1..<seed.count])
        ranges = try rangeSeeds.map { rangeSeed in
            let components = rangeSeed.components(separatedBy: CharacterSet.whitespaces).compactMap { Int($0) }
            guard components.count == 3 else { throw AoCError.wrongFormat }
            return Range(start: components[1], length: components[2], destination: components[0])
        }.sorted(by: { left, right in
            left.start < right.start
        })
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
    }
    return currentValues.min()!
}

// Broken, takes too much time, switch to ranges instead.
private func parseSeeds(_ line: String) throws -> [Int] {
    let digits = line.components(separatedBy: CharacterSet.whitespaces).compactMap { Int($0) }
    guard digits.count % 2 == 0 else { throw AoCError.wrongFormat }
    var seeds = [Int]()
    (0..<(digits.count / 2)).forEach { step in
        let index = step * 2
        (digits[index]..<(digits[index]+digits[index+1])).forEach { seeds.append($0) }
    }
    return seeds
}

private struct BlmanacMap {

    struct Range {
        let start: Int
        let length: Int
        let destination: Int

        func convert(source: Int) -> Int {
            return destination + source - start
        }

        func contains(item: Int) -> Bool {
            return (start..<start+length).contains(item)
        }

        // (95, 5) -> 95, 96, 97, 98, 99 -> (95, 3) + (98, 2)
        // Range -> 50, L48, D52
        // convert to -> 97, 98, 99, 50, 51
        // (97, 3) + (50, 2)
        func convert(fullyContainedDataRange dataRange: DataRange) throws -> DataRange {
            guard fullyContains(dataRange: dataRange) else {
                throw AoCError.wrongFormat
            }
            return DataRange(start: convert(source: dataRange.start), length: dataRange.length)
        }

        func fullyContains(dataRange: DataRange) -> Bool {
            return dataRange.start >= start
            && dataRange.start + dataRange.length <= start + length
        }

        func contains(dataRange: DataRange) -> Bool {
            return contains(item: dataRange.start)
        }
    }

    let ranges: [Range]

    init(seed: [String]) throws {
        let rangeSeeds = Array(seed[1..<seed.count])
        ranges = try rangeSeeds.map { rangeSeed in
            let components = rangeSeed.components(separatedBy: CharacterSet.whitespaces).compactMap { Int($0) }
            guard components.count == 3 else { throw AoCError.wrongFormat }
            return Range(start: components[1], length: components[2], destination: components[0])
        }.sorted(by: { left, right in
            left.start < right.start
        })
    }

    func convert(dataRange: DataRange) throws -> DataRange {
        guard let foundRange = (ranges.first { range in
            range.fullyContains(dataRange: dataRange)
        }) else {
            return dataRange
        }
        return try foundRange.convert(fullyContainedDataRange: dataRange)
    }
}


private struct DataRange: CustomStringConvertible {
    let start: Int
    let length: Int

    func split(accordingTo blmanacMap: BlmanacMap) -> [DataRange] {
        var resultRanges = [DataRange]()
        var currentInput = self
        var processingDone = false
        blmanacMap.ranges.forEach { range in
            guard !processingDone else { return }
            // if input is left outOfBounds { split until the beginning of current range, reassign leftover and continue }
            if currentInput.start < range.start { // At least partially left outOfBounds
                if currentInput.start + currentInput.length < range.start { // fully left outOfBounds
                    // leave as is, end of function
                    resultRanges.append(currentInput)
                    processingDone = true
                } else { // overlaps leftOutside and range
                    // split
                    let outsideLength = range.start - currentInput.start
                    let leftRange = DataRange(start: currentInput.start, length: outsideLength)
                    resultRanges.append(leftRange)
                    // assign leftover if it exists and continue
                    let leftOverRange = currentInput.length - outsideLength
                    if leftOverRange > 0 {
                        let leftover = DataRange(start: range.start, length: currentInput.length - outsideLength)
                        currentInput = leftover
                    }
                }
            }
            if range.fullyContains(dataRange: currentInput) {
                // if input is fullyContained { keep as is, end of function }
                resultRanges.append(currentInput)
                processingDone = true
                return
            }
            // if input is partly contained (can overflow on the right)
            if range.contains(dataRange: currentInput) {
                // split until the end of current range, reassign leftover and loop
                let containedLength = range.start + range.length - currentInput.start
                let containedRange = DataRange(start: currentInput.start, length: containedLength)
                resultRanges.append(containedRange)
                let leftOverRange = DataRange(
                    start: currentInput.start + containedLength,
                    length: currentInput.length - containedLength
                )
                currentInput = leftOverRange
            }
        }
        if !processingDone {
            // We have a right leftover, add as is
            resultRanges.append(currentInput)
        }
        return resultRanges
    }

    var description: String {
        return "(start: \(start); length: \(length))\n"
    }
}

private func parseDataRanges(_ line: String) throws -> [DataRange] {
    let digits = line.components(separatedBy: CharacterSet.whitespaces).compactMap { Int($0) }
    guard digits.count % 2 == 0 else { throw AoCError.wrongFormat }
    return (0..<(digits.count / 2)).map { step in
        let index = step * 2
        return DataRange(start: digits[index], length: digits[index+1])
    }
}

func day5_2023_B() throws -> Int {
    var groupedLines = try FileReader(filename: "day5_2023_input").getGroupedLines()
    let input = try parseDataRanges(groupedLines[0].first!)
    groupedLines = Array(groupedLines[1..<groupedLines.count])
    var currentInput = input
//    print(currentInput)
    try groupedLines.forEach { almanacSeed in
        let currentAlmanacMap = try BlmanacMap(seed: almanacSeed)
        currentInput = currentInput.flatMap { range in
            range.split(accordingTo: currentAlmanacMap)
        }
//        print("Split into")
//        print(currentInput)
        currentInput = try currentInput.map { newRange in
            try currentAlmanacMap.convert(dataRange: newRange)
        }
//        print("Maps to")
//        print(currentInput)
    }
    return currentInput.map { $0.start }.min()!
}
