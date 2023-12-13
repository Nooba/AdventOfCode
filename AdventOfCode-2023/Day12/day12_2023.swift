//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private struct Row {
    enum Status: String {
        case unknown = "?"
        case damaged = "#"
        case operational = "."
    }

    let springs: [Status]
    let record: [Int]

    init(string: String) {
        let components = string.components(separatedBy: .whitespaces)
        springs = components[0].compactMap { Status(rawValue: String($0)) }
        record = components[1].compactMap { Int(String($0)) }
    }
}

private func process(_ line: String) throws -> Int {
    let row = Row(string: line)
    return -1
}

func day12_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day12_2023_example").getLines()
    let results = try lines.map(process(_:))
    return results.reduce(0, +)
}

// MARK: - Part 2

func day12_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day12_2023_example").getLines()
    return -1
}
