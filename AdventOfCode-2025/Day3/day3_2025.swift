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

fileprivate var enabled = true

private func parseLinePartB(_ line: String) throws -> Int {
    var result = 0
    try parseRegexp(line, capturePattern: #"mul\(\d{1,3},\d{1,3}\)|do\(\)|don't\(\)"#, getAllMatches: true) { groups in
        let mapped = groups.compactMap { group -> String? in
            if group == "do()" {
                enabled = true
                return nil
            } else if group == "don't()" {
                enabled = false
                return nil
            } else if enabled {
                return group.replacingOccurrences(of: "mul(", with: "").replacingOccurrences(of: ")", with: "")
            }
            return nil
        }
        let components = mapped.map { $0.components(separatedBy: ",") }
        let values = components.map { $0.map { Int($0)! }.reduce(1, *) }
        result += values.reduce(0, +)
    }
    return result
}


func day3_2025_B() throws -> Int {
    let lines = try FileReader(filename: "day3_2025_input").getLines()
    return try lines.map { try parseLinePartB($0) }.reduce(0, +)
}
