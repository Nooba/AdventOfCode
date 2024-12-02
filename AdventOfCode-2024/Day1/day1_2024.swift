//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation

private func parseLine(_ line: String) throws -> (Int, Int) {
    let ints = (line.components(separatedBy: .whitespacesAndNewlines)).compactMap { Int($0) }
    guard ints.count == 2 else {
        throw AoCError.wrongFormat
    }
    return (ints[0], ints[1])
}

func day1_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day1_2024_input").getLines()
    let numbers = try lines.map(parseLine(_:))
    let lefts = numbers.map { $0.0 }.sorted()
    let rights = numbers.map { $0.1 }.sorted()
    guard lefts.count == rights.count else { throw AoCError.wrongFormat }
    var result = 0
    for (left, right) in zip(lefts, rights) {
        result += abs(left - right)
    }
    return result
}
