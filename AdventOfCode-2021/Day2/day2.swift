//
//  day2.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

fileprivate enum Command: String {
    case forward
    case up
    case down
}

func day2_A() throws -> Int {
    let lines = try FileReader(filename: "day2_input").getLines()
    var position = 0
    var depth = 0
    try lines.forEach({ line in
        let components = line.components(separatedBy: .whitespaces)
        guard components.count == 2,
              let commandString = components.first,
              let command = Command(rawValue: commandString),
              let valueString = components.last,
              let value = Int(valueString) else {
            throw AoCError.wrongFormat
        }
        switch command {
        case .forward:
            position += value
        case .up:
            depth -= value
        case .down:
            depth += value
        }
    })
    return position * depth
}

func day2_B() throws -> Int {
    let lines = try FileReader(filename: "day2_input").getLines()
    var aim = 0
    var position = 0
    var depth = 0
    try lines.forEach({ line in
        let components = line.components(separatedBy: .whitespaces)
        guard components.count == 2,
              let commandString = components.first,
              let command = Command(rawValue: commandString),
              let valueString = components.last,
              let value = Int(valueString) else {
            throw AoCError.wrongFormat
        }
        switch command {
        case .forward:
            position += value
            depth += aim * value
        case .up:
            aim -= value
        case .down:
            aim += value
        }
    })
    return position * depth
}
