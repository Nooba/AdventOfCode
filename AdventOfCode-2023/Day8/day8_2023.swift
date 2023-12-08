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

private struct Branch: CustomStringConvertible {
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

private func parseMap(_ lines: [String]) throws -> [String: Branch] {
    var map: [String: Branch] = [:]
    try lines.forEach { line in
        try parseRegexp(line, capturePattern: #"(\S{3}) = \((\S{3}), (\S{3})\)"#) { groups in
            map[groups[0]] = Branch(left: groups[1], right: groups[2])
        }
    }
    return map
}

private func process(_ map: [String: Branch], instructions: [Direction]) -> Int {
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

private struct Position {
    let nodes: [String]

    var isFinished: Bool {
        return nodes.allSatisfy { $0.hasSuffix("Z") }
    }
}

private func parseStartingPosition(nodes: [String]) -> Position {
    return Position(nodes: nodes.filter { $0.hasSuffix("A") })
}

private func process(startingPosition: Position, map: [String: Branch], instructions: [Direction]) -> Int {
    var currentPos = startingPosition
    var counter = 0
    while !currentPos.isFinished {
        print(currentPos.nodes)
        let instruction = instructions[counter % instructions.count]
        let mappedNodes = currentPos.nodes.map { node in
            return map[node]![instruction]
        }
        currentPos = Position(nodes: mappedNodes)
        counter += 1
    }
    return counter
}


func day8_2023_B() throws -> Int {
    let groupedLines = try FileReader(filename: "day8_2023_input").getGroupedLines()
    let instructions = parseInstructions(groupedLines[0].first!)
    let mapStrings = groupedLines[1]
    let map = try parseMap(mapStrings)
    let positions = parseStartingPosition(nodes: Array(map.keys))
    let loops = positions.nodes.map { startingNode in
        process(startingPosition: Position(nodes: [startingNode]), map: map, instructions: instructions)
    }
    // Bruteforcing by processing the loops at the same time is too long, the example / definition of the problem shows
    // a cycle between the example loops. Thus the idea that it must be the Least Common Multiple between each loops
    // cycle
    return lcm(loops)
}
