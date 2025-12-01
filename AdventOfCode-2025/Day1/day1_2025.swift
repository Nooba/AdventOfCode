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
//    let lefts = numbers.map { $0.0 }.sorted()
//    let rights = numbers.map { $0.1 }.sorted()
//    guard lefts.count == rights.count else { throw AoCError.wrongFormat }
//    let similarityScore = lefts.map { left in
//        return left * rights.filter { left == $0 }.count
//    }
//    return similarityScore.reduce(0, +)
    return -1
}
