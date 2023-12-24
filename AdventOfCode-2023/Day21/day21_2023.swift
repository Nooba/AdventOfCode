//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private class Node: CustomStringConvertible {
    enum NodeType: String {
        case gardenPlot = "."
        case rock = "#"
    }

    let type: NodeType
    var isOn: Bool

    init(type: NodeType, isOn: Bool) {
        self.type = type
        self.isOn = isOn
    }

    init(string: String) {
        if let type = NodeType(rawValue: string) {
            self.type = type
            isOn = false
        } else if string == "S" {
            self.type = .gardenPlot
            isOn = true
        } else {
            fatalError()
        }
    }

    func copy() -> Node {
        return Node(type: type, isOn: isOn)
    }

    var description: String {
        isOn ? "0" : type.rawValue
    }
}

private typealias Position = (Int, Int)

private class Map<N: CustomStringConvertible>: CustomStringConvertible {
    struct Row: CustomStringConvertible {
        var nodes: [N]

        init(string: String, nodeInitializer: ((String) -> N)) throws{
            nodes = string.compactMap {  nodeInitializer(String($0)) }
            guard nodes.count == string.count else { throw AoCError.wrongFormat }
        }

        var description: String {
            nodes.map { $0.description }.joined()
        }
    }

    var rows: [Row]

    var description: String {
        rows.map { $0.description }.joined(separator: "\n")
    }

    func getColumn(at index: Int) -> [N] {
        return rows.map { $0.nodes[index] }
    }

    func getColumns(in range: ClosedRange<Int>) -> [[N]] {
        return range.map { index in
            getColumn(at: index)
        }
    }

    var xCount: Int {
        return rows[0].nodes.count
    }

    var yCount: Int {
        return rows.count
    }

    init(rows: [Row]) {
        self.rows = rows
    }

    convenience init(mapString: [String], nodeInitializer: ((String) -> N)) throws {
        self.init(rows: try mapString.map { try Row(string: $0, nodeInitializer: nodeInitializer) })
    }

    subscript(position: Position) -> N? {
        rows[safe: position.1]?.nodes[safe: position.0]
    }

    func update(node: N, at position: Position) {
        rows[position.1].nodes[position.0] = node
    }
}

private extension Map.Row where N == Node {

    private init(nodes: [Node]) {
        self.nodes = nodes
    }

    func copy() -> Map.Row {
        Map.Row(nodes: nodes.map { $0.copy() })
    }
}

private extension Map where N == Node {
    func copy() -> Map {
        return Map(rows: rows.map { $0.copy() })
    }

    var onNodes: Int {
        rows.map { $0.nodes.filter { $0.isOn }.count }.reduce(0, +)
    }
}

private func parse(_ lines: [String]) throws -> Map<Node> {
    return try Map<Node>(mapString: lines) { Node(string: $0) }
}

private func step(map: Map<Node>) -> Map<Node> {
    let copy = map.copy()
    (0..<map.xCount).forEach { x in
        (0..<map.yCount).forEach { y in
            let position = Position(x, y)
            let currentNode = copy[position]!
            guard currentNode.type == .gardenPlot else { return }
            let topNode = map[(x, y-1)]
            let leftNode = map[(x-1, y)]
            let bottomNode = map[(x, y+1)]
            let rightNode = map[(x+1, y)]
            currentNode.isOn = (topNode?.isOn ?? false)
            || (leftNode?.isOn ?? false)
            || (bottomNode?.isOn ?? false)
            || (rightNode?.isOn ?? false)
            copy.update(node: currentNode, at: position)
        }
    }
    return copy
}

func day21_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day21_2023_input").getLines()
    var map = try parse(lines)
//    print(map)
    (0..<64).forEach { _ in
        map = step(map: map)
//        print(map)
    }
    return map.onNodes
}

// MARK: - Part 2

func day21_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day21_2023_example").getLines()
    return -1
}
