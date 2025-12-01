//
//  day1_2025.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2025.
//

import Foundation

private enum Direction: String {
    case left = "L"
    case right = "R"
}

private struct Instruction {
    let direction: Direction
    let steps: Int
}

private func parseLine(_ line: String) throws -> Instruction {
    let direction = Direction(rawValue: String(line.first!))!
    let steps = Int(line[line.index(after: line.startIndex)..<line.endIndex])!
    return Instruction(direction: direction, steps: steps)
}


func day1_2025_A() throws -> Int {
    let lines = try FileReader(filename: "day1_2025_input").getLines()
    let instructions = try lines.map(parseLine(_:))
    var value = 50
    var result = 0
    instructions.forEach { instruction in
        switch instruction.direction {
        case .left:
            value -= instruction.steps
        case .right:
            value += instruction.steps
        }
        value = value % 100
        if value == 0 {
            result += 1
        }
    }
    return result
}

func day1_2025_B() throws -> Int {
    let lines = try FileReader(filename: "day1_2025_input").getLines()
    let instructions = try lines.map(parseLine(_:))
    var value = 50
    var result = 0
    instructions.forEach { instruction in
//        dump(instruction)
        let previous = value
        let minimumSteps = instruction.steps % 100
        result += instruction.steps / 100
        guard minimumSteps > 0 else {
            return
        }
        switch instruction.direction {
        case .left:
            value -= minimumSteps
        case .right:
            value += minimumSteps
        }
//        dump(value)
        defer {
            if value < 0 {
                value += 100
            }
            value = value % 100
//            dump(result)
//            dump("-----")
        }
        if previous == 0 {
            return
        }
        if value >= 100 || value <= 0 {
            result += 1
            return
        }
    }
    return result
}
