//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

private enum Instruction: String {
    case on
    case off
    case toggle
}

private struct Position: Hashable {
    let x: Int
    let y: Int
}

private struct Rectangle {
    let topLeft: Position
    let bottomRight: Position
}

private struct Line {
    let instruction: Instruction
    let rectangle: Rectangle
}

private func parse(_ string: String) throws -> Line {
    return try parseRegexp(string, capturePattern: #"(turn (on|off)|(toggle)) (\d+),(\d+) through (\d+),(\d+)"#) { groups in
        Line(
            instruction: Instruction(rawValue: groups[1])!,
            rectangle: Rectangle(
                topLeft: Position(x: Int(groups[2])!, y: Int(groups[3])!),
                bottomRight: Position(x: Int(groups[4])!, y: Int(groups[5])!)
            )
        )
    }
}

func day6_2015_A() throws -> Int {
    let lines = try FileReader(filename: "day6_2015_input").getLines()
    var hash: [Position: Bool] = [:]
    let linesInstructions = try lines.map(parse(_:))
    linesInstructions.forEach { line in
        (line.rectangle.topLeft.x...line.rectangle.bottomRight.x).forEach { x in
            (line.rectangle.topLeft.y...line.rectangle.bottomRight.y).forEach { y in
                let position = Position(x: x, y: y)
                switch line.instruction {
                case .on:
                    hash[position] = true
                case .off:
                    hash[position] = false
                case .toggle:
                    let value = hash[position] ?? false
                    hash[position] = !value
                }
            }
        }
    }
    return hash.values.filter { $0 }.count
}

// MARK: - Part 2

private struct Light {
    let brightness: Int

    func copy(change: Int) -> Light {
        return Light(brightness: max(brightness + change, 0))
    }
}

func day6_2015_B() throws -> Int {
    let lines = try FileReader(filename: "day6_2015_input").getLines()
    var hash: [Position: Light] = [:]
    let linesInstructions = try lines.map(parse(_:))
    linesInstructions.forEach { line in
        (line.rectangle.topLeft.x...line.rectangle.bottomRight.x).forEach { x in
            (line.rectangle.topLeft.y...line.rectangle.bottomRight.y).forEach { y in
                let position = Position(x: x, y: y)
                let light = hash[position] ?? Light(brightness: 0)
                switch line.instruction {
                case .on:
                    hash[position] = light.copy(change: 1)
                case .off:
                    hash[position] = light.copy(change: -1)
                case .toggle:
                    hash[position] = light.copy(change: 2)
                }
            }
        }
    }
    return hash.values.map { $0.brightness }.reduce(0, +)

}
