//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private class Node {
    enum NodeType: String {
        case galaxy = "#"
        case void = "."
    }

    let type: NodeType

    init(string: String) throws {
        guard let type = NodeType(rawValue: string) else {
            throw AoCError.wrongFormat
        }
        self.type = type
    }
}

private class Map: CustomStringConvertible {
    struct Row {
        var nodes: [Node]

        init(row: String) throws {
            nodes = try row.map { try Node(string: String($0)) }
        }

        subscript(x: Int) -> Node? {
            nodes[safe: x]
        }
    }

    var rows: [Row]

    init(rowsString: [String]) throws {
        rows = try rowsString.map { try Row(row: $0) }
    }

    var description: String {
        return rows.map { row in
            return row.nodes.map { $0.type.rawValue }.joined()
        }.joined(separator: "\n")
    }

    subscript(y: Int) -> Row? {
        rows[safe: y]
    }

    subscript(position: (Int, Int)) -> Node? {
        self[position.1]?[position.0]
    }
}

private func process(_ lines: [String], growthOffset: Int) throws -> Int {
    let map = try Map(rowsString: lines)
    var galaxies: [(Int, Int)] = []
    map.rows.enumerated().forEach { (rowIndex, row) in
        row.nodes.enumerated().forEach { (nodeIndex, node)  in
            if node.type == .galaxy {
                galaxies.append((nodeIndex, rowIndex))
            }
        }
    }
    let voidRows = map.rows.enumerated().compactMap { (rowIndex, row) -> Int? in
        guard row.nodes.allSatisfy ({ $0.type == .void }) else { return nil }
        return rowIndex
    }
    let voidColumns = (0..<map.rows.first!.nodes.count).compactMap { xIndex -> Int? in
        guard (0..<map.rows.count).allSatisfy ({ map[(xIndex, $0)]?.type == .void }) else {
            return nil
        }
        return xIndex
    }
    var result: [Int] = []
    let end = galaxies.count-1
    (0..<end).forEach { pairStart in
        let nextStart: Int = pairStart + 1
        (nextStart..<galaxies.count).forEach { pairEnd in
            let first = galaxies[pairStart]
            let second = galaxies[pairEnd]
            let distance = abs(second.1 - first.1) + abs(second.0 - first.0)
            let xRange = (min(first.0, second.0)...max(first.0, second.0))
            let yRange = (min(first.1, second.1)...max(first.1, second.1))
            let xOffset = voidColumns.filter { xRange.contains($0) }.count * (growthOffset - 1)
            let yOffset = voidRows.filter { yRange.contains($0) }.count * (growthOffset - 1)
            let totalDistance = distance + xOffset + yOffset
            result.append(totalDistance)
        }
    }
    return result.reduce(0, +)
}

func day11_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day11_2023_input").getLines()
    return try process(lines, growthOffset: 2)
}

// MARK: - Part 2

func day11_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day11_2023_input").getLines()
    return try process(lines, growthOffset: 1000000)
}
