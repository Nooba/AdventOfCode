//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private func memoryCount(string: String) throws -> Int {
    let matches = string.matches(of: try Regex(#"\\(\\|")"#))
    let escapedCount = string.matches(of: try Regex(#"\\(\\|")"#)).count
    var temporary = string.replacingOccurrences(of: "\\\\", with: "")
    temporary = temporary.replacingOccurrences(of: "\\\"", with: "")
    // This prevents an issue where we would read `"oh\\x\\h"` as an encodedCount of 1
    let encodedCount = temporary.matches(of: try Regex(#"\\x"#)).count
    return string.count - escapedCount - encodedCount * 3 - 2
}

func day8_2015_A() throws -> Int {
    let lines = try FileReader(filename: "day8_2015_input").getLines()
    let counts = lines.map { $0.count }.reduce(0, +)
    let memoryCounts = try lines.map(memoryCount(string:)).reduce(0, +)
    return counts - memoryCounts
}

// MARK: - Part 2

private func encode(string: String) -> String {
    let encoded = string.map { character -> String in
        switch character {
        case "\\":
            return "\\\\"
        case "\"":
            return "\\\""
        default:
            return String(character)
        }
    }.joined()
    return "\"\(encoded)\""
}

func day8_2015_B() throws -> Int {
    let lines = try FileReader(filename: "day8_2015_example").getLines()
    let encoded = lines.map(encode(string:))
    let encodedCounts = encoded.map { $0.count }.reduce(0, +)
    let counts = lines.map { $0.count }.reduce(0, +)
    return encodedCounts - counts
}
