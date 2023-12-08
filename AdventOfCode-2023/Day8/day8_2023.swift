//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private enum Direction: String {
    case left = "L"
    case right = "R"
}

private struct Node: CustomStringConvertible {
    let left: String
    let right: String

    var description: String {
        return "(\(left), \(right))"
    }

    subscript(direction: Direction) -> String {
        switch direction {
        case .left:
            return left
        case .right:
            return right
        }
    }
}

private func parseInstructions(_ line: String) -> [Direction] {
    return line.map { Direction(rawValue: String($0))! }
}

private func parseMap(_ lines: [String]) throws -> [String: Node] {
    var map: [String: Node] = [:]
    try lines.forEach { line in
        try parseRegexp(line, capturePattern: #"(\D{3}) = \((\D{3}), (\D{3})\)"#) { groups in
            map[groups[0]] = Node(left: groups[1], right: groups[2])
        }
    }
    return map
}

private func process(_ map: [String: Node], instructions: [Direction]) -> Int {
    var currentPos = "AAA"
    var counter = 0
    while currentPos != "ZZZ" {
        let instruction = instructions[counter % instructions.count]
        currentPos = map[currentPos]![instruction]
        counter += 1
    }
    return counter
}

func day8_2023_A() throws -> Int {
    let groupedLines = try FileReader(filename: "day8_2023_input").getGroupedLines()
    let instructions = parseInstructions(groupedLines[0].first!)
    let mapStrings = groupedLines[1]
    let map = try parseMap(mapStrings)
    return process(map, instructions: instructions)
}

// MARK: - Part 2

private func parseLineSecondPart(_ line: String) throws -> Int {
    return -1
}

func day8_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day8_2023_input").getLines()
    let numbers = try lines.map(parseLineSecondPart(_:))
    return numbers.reduce(0, +)
}
