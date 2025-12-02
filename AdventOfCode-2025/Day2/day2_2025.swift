//
//  day1_2025.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2025.
//

import Foundation

private extension Int {
    var isValid: Bool {
        let string = String(self)
        guard string.count.isMultiple(of: 2) else {
            return false
        }
        let mid = string.count / 2
        let startIndex = string.startIndex
        let middleIndex = string.index(startIndex, offsetBy: mid)
        let endIndex = string.endIndex
        let firstHalf = string[startIndex..<middleIndex]
        let secondHalf = string[middleIndex..<endIndex]
        return firstHalf == secondHalf
    }
}

private func parseLine(_ line: String) throws -> [Int] {
    return (line.components(separatedBy: .whitespacesAndNewlines)).compactMap { Int($0) }
}

private struct Tuple {
    let start: Int
    let end: Int

    init(string: String) {
        let comps = string.components(separatedBy: "-").map { Int($0) }
        start = comps[0]!
        end = comps[1]!
    }

    var invalidIds: [Int] {
        Array(start...end).filter(\.isValid)
    }
}

func day2_2025_A() throws -> Int {
    let line = try FileReader(filename: "day2_2025_input").getLines()[0]
    let tuples = line.components(separatedBy: ",").map { Tuple(string: $0) }
    return tuples.flatMap { $0.invalidIds }.reduce(0, +)
}

// MARK: - Part B

func day2_2025_B() throws -> Int {
    let lines = try FileReader(filename: "day2_2025_input").getLines()
    let reports = try lines.map(parseLine(_:))
    let unsafe = reports.filter { !isSafe(levels: $0) }
    let superUnsafe = unsafe.filter { unsafeReport in
        let length = unsafeReport.count
        var dampenedReports: [[Int]] = []
        for i in (0..<length) {
            var copy = unsafeReport
            copy.remove(at: i)
            dampenedReports.append(copy)
        }
        return !dampenedReports.contains { isSafe(levels: $0) }
    }
    return reports.count - superUnsafe.count
}

private func isSafe(levels: [Int]) -> Bool {
    var positiveSlope: Bool?
    var previous: Int!
    var isSafe = true
    print(levels)
    levels.enumerated().forEach { (index, element) in
        if !isSafe { return }
        if index == 0 {
            previous = element
            return
        }
        print(element)
        if index == 1 {
            positiveSlope = element >= previous
        }
        let abs = abs(element - previous)
        if abs > 3 {
            print("distance")
            isSafe = false
            return
        }
        if abs == 0 {
            print("flat slope")
            isSafe = false
            return
        }
        if (element >= previous) != positiveSlope {
            print("slope change")
            isSafe = false
            return
        }
        previous = element
    }
    return isSafe
}
