//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private struct Node: CustomStringConvertible {

    enum NodeType: String {
        case full = "."
        case dugOut = "#"
    }

    var type: NodeType
    var color: String?

    init(type: NodeType) {
        self.type = type
    }

    var description: String {
        return type.rawValue
    }
}

private class Map: CustomStringConvertible {

    class Row: CustomStringConvertible {
        var nodes: [Node]

        init(totalX: Int) {
            nodes = (0..<totalX).map { _ in Node(type: .full) }
//            nodes = Array(repeating: Node(type: .full), count: totalX)
        }

        var description: String {
            nodes.map { $0.description }.joined()
        }
    }

    let rows: [Row]

    init(totalX: Int, totalY: Int) {
        rows = (0..<totalY).map { _ in Row(totalX: totalX) }
    }

    subscript(position: Position) -> Node? {
        rows[safe: position.1]?.nodes[safe: position.0]
    }

    func update(node: Node, at position: Position) {
        rows[position.1].nodes[position.0] = node
    }

    func dig(at position: Position, with color: String?) {
        var node = self[position]!
        node.type = .dugOut
        node.color = color
        update(node: node, at: position)
    }

    var description: String {
        rows.map { $0.description }.joined(separator: "\n")
    }

    func getColumn(at index: Int) -> [Node] {
        return rows.map { $0.nodes[index] }
    }

}

private typealias Position = (Int, Int)

private struct Instruction: CustomStringConvertible {

    enum Direction: String {
        case up = "U"
        case down = "D"
        case left = "L"
        case right = "R"
    }

    let direction: Direction
    let distance: Int
    let hexColor: String

    var description: String {
        "Instruction \(direction.rawValue), distance: \(distance)"
    }
}

private func process(_ line: String) throws -> Instruction {
    return try parseRegexp(line, capturePattern: #"(D|U|L|R) (\d+) \(#(.+)\)"#) { groups in
        let direction = Instruction.Direction(rawValue: groups[0])!
        let distance = Int(groups[1])!
        let hexColor = groups[2]
        return Instruction(direction: direction, distance: distance, hexColor: hexColor)
    }
}

private func dig(_ map: Map, accordingTo instructions: [Instruction], startingAt position: Position) {
    var (currentX, currentY) = position
    map.dig(at: (currentX, currentY), with: "000000")
    instructions.forEach { instruction in
//        print("\n")
//        print(instruction)
        switch instruction.direction {
        case .up:
            (1...instruction.distance).forEach { step in
                map.dig(at: Position(at: currentX, currentY - step), with: instruction.hexColor)
            }
            currentY -= instruction.distance
        case .down:
            (1...instruction.distance).forEach { step in
                map.dig(at: Position(at: currentX, currentY + step), with: instruction.hexColor)
            }
            currentY += instruction.distance
        case .left:
            (1...instruction.distance).forEach { step in
                map.dig(at: Position(at: currentX - step, currentY), with: instruction.hexColor)
            }
            currentX -= instruction.distance
        case .right:
            (1...instruction.distance).forEach { step in
                map.dig(at: Position(at: currentX + step, currentY), with: instruction.hexColor)
            }
            currentX += instruction.distance
        }
//        print(map)
    }
}

private var digQueue: [Position] = []

private func testAndEnqueueIfValid(_ map: Map, position: Position) {
    guard let node = map[position], node.type == .full else {
        return
    }
    digQueue.append(position)
}

private func digIfPossible(_ map: Map, startingAt position: Position) throws {
    print("dig \(position)")
    guard let node = map[position], node.type == .full else {
        return
    }
    map.dig(at: position, with: nil)
    testAndEnqueueIfValid(map, position: Position(position.0, position.1+1))
    testAndEnqueueIfValid(map, position: Position(position.0, position.1-1))
    testAndEnqueueIfValid(map, position: Position(position.0+1, position.1))
    testAndEnqueueIfValid(map, position: Position(position.0-1, position.1))
}

private func fullyDig(_ map: Map) throws {
    let maxX = map.rows[0].nodes.count
    // This seems kinda weak but works here.
    let foundColumn = (0..<maxX).first { currentX in
        let topIsDugOut = map[(currentX, 0)]!.type == .dugOut
        let bottomIsInside = map[(currentX, 1)]!.type == .full
        return topIsDugOut && bottomIsInside
    }
    digQueue.append(Position(foundColumn!, 1))
    while !digQueue.isEmpty {
        try digIfPossible(map, startingAt: digQueue.removeFirst())
    }
}

private func process(instructions: [Instruction]) throws -> Int {
    // find size and defaultPosition
    var (currentX, currentY) = (0, 0)
    var (minX, maxX, minY, maxY) = (0, 0, 0, 0)
    instructions.forEach { instruction in
        switch instruction.direction {
        case .up:
            currentY -= instruction.distance
            if minY > currentY { minY = currentY }
        case .down:
            currentY += instruction.distance
            if maxY < currentY { maxY = currentY }
        case .left:
            currentX -= instruction.distance
            if minX > currentX { minX = currentX }
        case .right:
            currentX += instruction.distance
            if maxX < currentX { maxX = currentX }
        }
    }
    print(minX, maxX, minY, maxY)
    let totalX = maxX - minX + 1
    let totalY = maxY - minY + 1
    let map = Map(totalX: totalX, totalY: totalY)
    dig(map, accordingTo: instructions, startingAt: (-minX, -minY))
    print(map)
    try fullyDig(map)
    return map.rows.flatMap { $0.nodes }.filter { $0.type == .dugOut }.count
}

func day18_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day18_2023_input").getLines()
    let instructions = try lines.map(process(_:))
    return try process(instructions: instructions)
}

// MARK: - Part 2

func day18_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day18_2023_example").getLines()
    _ = try lines.map(process(_:))
    return -1
}
