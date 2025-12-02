//
//  day1_2025.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2025.
//

import Foundation

private extension Int {
    var isInvalid: Bool {
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
        Array(start...end).filter(\.isInvalid)
    }
}

func day2_2025_A() throws -> Int {
    let line = try FileReader(filename: "day2_2025_input").getLines()[0]
    let tuples = line.components(separatedBy: ",").map { Tuple(string: $0) }
    return tuples.flatMap { $0.invalidIds }.reduce(0, +)
}

// MARK: - Part B

private extension Int {
    var isInvalidPartB: Bool {
        let string = String(self)
        let startIndex = string.startIndex
        var isValid = true
        guard string.count > 1 else { return false }
        for i in 1...string.count / 2 {
            guard isValid else { continue }
            let length = i
            guard string.count.isMultiple(of: i) else { continue }
            let pattern = string[startIndex..<string.index(startIndex, offsetBy: length)]
            let amount = string.count / length
            var keepTestingI = true
            for j in 1..<amount {
                guard keepTestingI else { continue }
                let nextStart = string.index(startIndex, offsetBy: j * length)
                let end = string.index(nextStart, offsetBy: length)
                let nextPattern = string[nextStart..<end]
                if nextPattern != pattern {
                    keepTestingI = false
                }
            }
            if keepTestingI {
                isValid = false
            }
        }
        return !isValid
    }
}

private extension Tuple {
    var invalidIdsPartB: [Int] {
        Array(start...end).filter { $0.isInvalidPartB }
    }
}

func day2_2025_B() throws -> Int {
    let line = try FileReader(filename: "day2_2025_input").getLines()[0]
    let tuples = line.components(separatedBy: ",").map { Tuple(string: $0) }
    let invalids = tuples.flatMap { $0.invalidIdsPartB }
    return invalids.reduce(0, +)
}
