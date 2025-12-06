//
//  day1_2025.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2025.
//

import Foundation

private enum Operation: String {
    case add = "+"
    case multiply = "*"
}

func day6_2025_A() throws -> Int {
    let lines = try FileReader(filename: "day6_2025_input").getLines()
    let components = lines.map { $0.components(separatedBy: .whitespaces).filter { !$0.isEmpty } }
    let max = components[0].count
    var result = 0
    for i in 0..<max {
        var integers = [Int]()
        components.enumerated().forEach { (rowIndex, row) in
            if rowIndex < (components.count - 1) {
                integers.append(Int(components[rowIndex][i])!)
            } else {
                switch Operation(rawValue: components[rowIndex][i]) {
                case .add:
                    result += integers.reduce(0, +)
                case .multiply:
                    result += integers.reduce(1, *)
                case .none:
                    assertionFailure("Error")
                }
            }
        }
    }
    return result
}

// MARK: - Part B

func day6_2025_B() throws -> Int {
    let lines = try FileReader(filename: "day6_2025_input").getLines(trim: false)
    let max = lines.map(\.count).max()!
    var result = 0
    var integers: [Int] = []
    for i in (0..<max).reversed() {
        var currentInteger = 0
        for j in 0..<lines.count {
            let line = lines[j]
            let index = line.index(line.startIndex, offsetBy: i)
            let char = i < line.count ? line[index] : " "
            if j < lines.count - 1 {
                if let intValue = Int(String(char)) {
                    currentInteger = currentInteger * 10 + intValue
                }
            } else {
                if currentInteger != 0 {
                    integers.append(currentInteger)
                    currentInteger = 0
                }
                switch Operation(rawValue: String(char)) {
                case .add:
                    result += integers.reduce(0, +)
                    integers = []
                case .multiply:
                    result += integers.reduce(1, *)
                    integers = []
                case .none:
                    break
                }
            }
        }
    }
    return result
}
