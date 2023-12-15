//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private func hash(label: String) -> Int {
    var value = 0
    label.forEach { character in
        value = ((value + Int(character.asciiValue!)) * 17) % 256
    }
//    print("label: \(label), value: \(value)")
    return value
}

private func process(_ line: String) throws -> [Int] {
    return line.components(separatedBy: ",").map(hash(label:))
}

func day15_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day15_2023_input").getLines()
    return try process(lines[0]).reduce(0, +)
}

// MARK: - Part 2

func day15_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day15_2023_example").getLines()
    let results = try lines.map(process(_:))
    return -1
}
