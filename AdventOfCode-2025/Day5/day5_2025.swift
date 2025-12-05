//
//  day1_2025.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2025.
//

import Foundation

func day5_2025_A() throws -> Int {
    let lines = try FileReader(filename: "day5_2025_input").getGroupedLines()
    let freshRanges = lines[0].map {
        let components = $0.components(separatedBy: "-")
        return Int(components[0])!...Int(components[1])!
    }
    let result = lines[1].reduce(into: 0) { partialResult, element in
        let id = Int(element)!
        if freshRanges.first(where: { $0.contains(id) }) != nil {
            partialResult += 1
        }
    }
    return result
}

// MARK: - Part B

func day5_2025_B() throws -> Int {
    let lines = try FileReader(filename: "day5_2025_input").getGroupedLines()
    let freshRanges = lines[0].map {
        let components = $0.components(separatedBy: "-")
        return Int(components[0])!...Int(components[1])!
    }
    // Too slow
//    var resultSet = Set<Int>()
//    freshRanges.enumerated().forEach { (index, element) in
//        print(index)
//        resultSet.formUnion(element)
//    }
//    return resultSet.count

    // Too slow
//    var result = 0
//    freshRanges.enumerated().forEach { (index, range) in
//        print(index)
//        result += freshRanges.count
//        range.forEach { element in
//            result -= freshRanges.reduce(into: 0) { partialResult, testedRange in
//                guard testedRange != range else { return }
//                partialResult += testedRange.contains(element) ? 1 : 0
//            }
//        }
//    }
//    return result

    // We need to merge together ranges when possible
    var rangesIteration = freshRanges.sorted { (leftRange: ClosedRange<Int>, rightRange: ClosedRange<Int>) in
        if leftRange.lowerBound < rightRange.lowerBound {
            return true
        } else if leftRange.lowerBound == rightRange.lowerBound {
            return leftRange.upperBound < rightRange.upperBound
        }
        return false
    }
    var nextRangesIteration = [ClosedRange<Int>]()
    var keepReducing = true
    while keepReducing {
        var usedRanges: [ClosedRange<Int>: Bool] = rangesIteration.reduce(into: [:]) { partialResult, range in
            partialResult[range] = false
        }
        rangesIteration.forEach { leftRange in
            guard let rangeToMerge = (rangesIteration.first { rightRange in
                guard leftRange != rightRange else { return false }
                guard usedRanges[rightRange] == false else { return false}
                return leftRange.contains(rightRange.lowerBound) && rightRange.upperBound > leftRange.upperBound
            }) else {
                if usedRanges[leftRange] == false {
                    nextRangesIteration.append(leftRange)
                    usedRanges[leftRange] = true
                }
                return
            }
            let mergedRanges = leftRange.lowerBound...rangeToMerge.upperBound
            nextRangesIteration.append(mergedRanges)
            usedRanges[leftRange] = true
            usedRanges[rangeToMerge] = true
        }
        keepReducing = nextRangesIteration.count != rangesIteration.count
        rangesIteration = nextRangesIteration
            .filter { leftRange in
                if let foundRange = (nextRangesIteration.first(where: { rightRange in
                    rightRange.contains(leftRange)
                })) {
                    guard foundRange != leftRange else { return true }
                    return false
                }
                return true
            }
            .sorted { (leftRange: ClosedRange<Int>, rightRange: ClosedRange<Int>) in
            if leftRange.lowerBound < rightRange.lowerBound {
                return true
            } else if leftRange.lowerBound == rightRange.lowerBound {
                return leftRange.upperBound < rightRange.upperBound
            }
            return false
        }

        nextRangesIteration = [ClosedRange<Int>]()
    }
    print(rangesIteration)
    return rangesIteration.reduce(into: 0) { partialResult, range in
        partialResult += range.count
    }
}

// 318990863109998 - too Low
// 335107036446171 - too Low
// 335427609353607 - Incorrect
// 355869632640118 - too High
