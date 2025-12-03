//
//  day1_2025.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2025.
//

import Foundation

func day3_2025_A() throws -> Int {
    let lines = try FileReader(filename: "day3_2025_input").getLines()
    let results = lines.map { line in
        var first = 0
        var second = 0
        line.forEach { char in
            let current = Int(String(char))!
            if current >= second {
                if first < second {
                    first = second
                }
                second = current
            } else if second > first {
                first = second
                second = current
            }
        }
        return first * 10 + second
    }
//    print(results)
    return results.reduce(0, +)
}

// MARK: - Part B

func day3_2025_B() throws -> Int {
    let lines = try FileReader(filename: "day3_2025_input").getLines()
    let count = 12
    let results = lines.map { line in
        let subEndIndex = line.index(line.startIndex, offsetBy: count)
        var joltage = String(
            line[line.startIndex..<line.index(line.startIndex, offsetBy: count)]
        ).map { Int(String($0))! }
        let subLine = String(line[subEndIndex..<line.endIndex])
        subLine.forEach { char in
            let current = Int(String(char))!
            var keepChecking = true
            // Find j from end such that joltage[k] < joltage[k+1]
            // slide everything from k to end + add current at end
            for j in (1..<count) {
                guard keepChecking else { continue }
                if joltage[j - 1] < joltage[j] {
                    for k in (j-1..<count-1) {
                        joltage[k] = joltage[k+1]
                    }
                    joltage[count-1] = current
                    keepChecking = false
                }
            }
            if keepChecking && joltage[count-1] < current {
                joltage[count-1] = current
            }
        }
        return Int(joltage.map { "\($0)" }.joined())!
    }
    print(results)
    return results.reduce(0, +)
}
