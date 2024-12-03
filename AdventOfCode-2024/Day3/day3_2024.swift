//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation

private func parseLine(_ line: String) throws -> Int {
    var result = 0
    try parseRegexp(line, capturePattern: #"mul\(\d{1,3},\d{1,3}\)"#, getAllMatches: true) { groups in
        let mapped = groups.map { $0.replacingOccurrences(of: "mul(", with: "").replacingOccurrences(of: ")", with: "") }
        let components = mapped.map { $0.components(separatedBy: ",") }
        let values = components.map { $0.map { Int($0)! }.reduce(1, *) }
        result += values.reduce(0, +)
    }
    return result
}

func day3_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day3_2024_input").getLines()
    return try lines.map { try parseLine($0) }.reduce(0, +)
}

// MARK: - Part B

var enabled = true

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


func day3_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day3_2024_input").getLines()
    return try lines.map { try parseLinePartB($0) }.reduce(0, +)
}
