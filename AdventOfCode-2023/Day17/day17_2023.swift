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
        case empty = "."
        case slashMirror = "/"
        case antislashMirror = "\\"
        case horizontalSplitter = "-"
        case verticalSplitter = "|"
    }

    let type: NodeType
    var energyValue: Int
    var visitingDirections: [Beam.Direction] = []

    var isEnergized: Bool {
        return energyValue > 0
    }

    init(character: Character) throws {
        guard let type = NodeType(rawValue: String(character)) else {
            throw AoCError.wrongFormat
        }
        self.type = type
        energyValue = 0
    }

    var description: String {
        return type.rawValue
    }
}

private class Map: CustomStringConvertible {

    class Row: CustomStringConvertible {
        var nodes: [Node]

        init(string: String) throws {
            nodes = try string.map { try Node(character: $0) }
        }

        var description: String {
            nodes.map { $0.description }.joined()
        }
    }

    let rows: [Row]

    init(strings: [String]) throws {
        rows = try strings.map { try Row(string: $0) }
    }

    subscript(position: Position) -> Node? {
        rows[safe: position.1]?.nodes[safe: position.0]
    }

    func update(node: Node, at position: Position) {
        rows[position.1].nodes[position.0] = node
    }

    var description: String {
        rows.map { $0.description }.joined(separator: "\n")
    }
}

private typealias Position = (Int, Int)

private class Beam: CustomStringConvertible {
    enum Direction: String {
        case up = "^"
        case down = "v"
        case left = "<"
        case right = ">"
    }

    var direction: Direction
    var position: Position

    init(direction: Direction, position: Position) {
        self.direction = direction
        self.position = position
    }

    var description: String {
        return "Beam: \(direction.rawValue) at \(position)"
    }
}

private var beams: [Beam] = [Beam(direction: .right, position: (0, 0))]
private var map: Map!

private func stepBeams() {
//    print(beams)
    beams = beams.flatMap { beam -> [Beam] in
        let position = beam.position
        guard var node = map[position], !node.visitingDirections.contains(beam.direction) else {
            return []
        }
        node.energyValue += 1
        node.visitingDirections.append(beam.direction)
        map.update(node: node, at: position)
        switch (beam.direction) {
        case .up:
            return stepUpBeam(at: position, of: node.type)
        case .down:
            return stepDownBeam(at: position, of: node.type)
        case .left:
            return stepLeftBeam(at: position, of: node.type)
        case .right:
            return stepRightBeam(at: position, of: node.type)
        }
    }
}

private func stepUpBeam(at position: Position, of type: Node.NodeType) -> [Beam] {
    switch type {
    case .empty, .verticalSplitter:
        return [Beam(direction: .up, position: Position(position.0, position.1 - 1))]
    case .slashMirror:
        return [Beam(direction: .right, position: Position(position.0 + 1, position.1))]
    case .antislashMirror:
        return [Beam(direction: .left, position: Position(position.0 - 1, position.1))]
    case .horizontalSplitter:
        return [
            Beam(direction: .left, position: Position(position.0 - 1, position.1)),
            Beam(direction: .right, position: Position(position.0 + 1, position.1))
        ]
    }
}

private func stepDownBeam(at position: Position, of type: Node.NodeType) -> [Beam] {
    switch type {
    case .empty, .verticalSplitter:
        return [Beam(direction: .down, position: Position(position.0, position.1 + 1))]
    case .slashMirror:
        return [Beam(direction: .left, position: Position(position.0 - 1, position.1))]
    case .antislashMirror:
        return [Beam(direction: .right, position: Position(position.0 + 1, position.1))]
    case .horizontalSplitter:
        return [
            Beam(direction: .left, position: Position(position.0 - 1, position.1)),
            Beam(direction: .right, position: Position(position.0 + 1, position.1))
        ]
    }
}

private func stepLeftBeam(at position: Position, of type: Node.NodeType) -> [Beam] {
    switch type {
    case .empty, .horizontalSplitter:
        return [Beam(direction: .left, position: Position(position.0 - 1, position.1))]
    case .slashMirror:
        return [Beam(direction: .down, position: Position(position.0, position.1 + 1))]
    case .antislashMirror:
        return [Beam(direction: .up, position: Position(position.0, position.1 - 1))]
    case .verticalSplitter:
        return [
            Beam(direction: .up, position: Position(position.0, position.1 - 1)),
            Beam(direction: .down, position: Position(position.0, position.1 + 1))
        ]
    }
}

private func stepRightBeam(at position: Position, of type: Node.NodeType) -> [Beam] {
    switch type {
    case .empty, .horizontalSplitter:
        return [Beam(direction: .right, position: Position(position.0 + 1, position.1))]
    case .slashMirror:
        return [Beam(direction: .up, position: Position(position.0, position.1 - 1))]
    case .antislashMirror:
        return [Beam(direction: .down, position: Position(position.0, position.1 + 1))]
    case .verticalSplitter:
        return [
            Beam(direction: .up, position: Position(position.0, position.1 - 1)),
            Beam(direction: .down, position: Position(position.0, position.1 + 1))
        ]
    }
}

private func process(_ lines: [String]) throws -> Int {
    map = try Map(strings: lines)
//    print(map!)
    while !beams.isEmpty {
        stepBeams()
    }
    return map.rows.flatMap { $0.nodes }.filter { $0.isEnergized }.count
}

func day17_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day17_2023_example").getLines()
    let results = try process(lines)
    return -1
}

// MARK: - Part 2

func day17_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day17_2023_example").getLines()
    let results = try process(lines)
    return -1
}
