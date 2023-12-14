//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private class Map: Equatable, CustomStringConvertible {
    static func == (lhs: Map, rhs: Map) -> Bool {
        return lhs.rows == rhs.rows
    }
    
    enum Node: String, Equatable, CustomStringConvertible {
        case empty = "."
        case cube = "#"
        case ball = "O"

        var description: String { return rawValue }
    }

    struct Row: Equatable, CustomStringConvertible {
        var nodes: [Node]

        init(nodes: [Node]) {
            self.nodes = nodes
        }

        init(string: String) throws{
            nodes = string.compactMap { Node(rawValue: String($0)) }
            guard nodes.count == string.count else { throw AoCError.wrongFormat }
        }

        var description: String {
            nodes.map { $0.description }.joined()
        }
    }

    var rows: [Row]

    func getColumn(at index: Int) -> [Node] {
        return rows.map { $0.nodes[index] }
    }

    func updateColumn(at index: Int, with column: [Node]) {
//        print(self)
        let mappedRows = rows.enumerated().map { (rowIndex, row) in
            var copy = row
            copy.nodes[index] = column[rowIndex]
            return copy
        }
        self.rows = mappedRows
//        print("updated to:")
//        print(self)
    }

    func getColumns(in range: ClosedRange<Int>) -> [[Node]] {
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

    init(mapString: [String]) throws {
        rows = try mapString.map { try Row(string: $0) }
    }

    var description: String {
        rows.map { $0.nodes.description }.joined(separator: "\n")
    }
}

private extension Array where Element == Map.Node {
    func components(separatedBy separator: Map.Node) -> [[Map.Node]] {
        var results: [[Map.Node]] = []
        var leftover = self
        while leftover.count > 0 {
            guard let splitIndex = leftover.firstIndex (where: { $0 == separator }) else {
                results.append(leftover)
                leftover = []
                break
            }
            results.append(Array(leftover[0..<splitIndex]))
            if leftover.count > splitIndex {
                leftover = Array(leftover[(splitIndex+1)..<leftover.count])
            } else {
                leftover = []
            }
        }
        return results
    }
}

private extension Array where Element == [Map.Node] {
    func joined(separator: Map.Node) -> [Map.Node] {
        var result: [Map.Node] = []
        (0..<self.count).forEach { index in
            result.append(contentsOf: self[index])
            if index != self.count - 1 {
                result.append(separator)
            }
        }
        return result
    }
}

private func northBearingWeight(_ map: Map) -> Int {
    let values = map.rows.enumerated().map { (rowIndex, row) in
        let ballCount = row.nodes.filter { $0 == .ball }.count
        return (map.yCount - rowIndex) * ballCount
    }
//    print(map.rows)
//    print(values)
    return values.reduce(0, +)
}

private func tiltVertically(_ map: Map, direction: Direction) throws {
    guard direction == .north || direction == .south else { throw AoCError.wrongFormat }
    let addBallFirst = direction == .north
    (0..<map.xCount).forEach { columnIndex in
        let column = map.getColumn(at: columnIndex)
//        print("column \(column)")
        var slices = column.components(separatedBy: .cube)
        slices = slices.map { slice in
            let ballCount = slice.filter { $0 == .ball } .count
            var updatedSlice = Array(repeating: Map.Node.ball, count: ballCount)
            var leftover = Array(repeating: Map.Node.empty, count: slice.count - ballCount)
            if addBallFirst {
                updatedSlice.append(contentsOf: leftover)
                return updatedSlice
            } else {
                leftover.append(contentsOf: updatedSlice)
                return leftover
            }
        }
        var updatedColumn = slices.joined(separator: .cube)
        while updatedColumn.count < column.count {
            updatedColumn.append(.cube)
        }
        map.updateColumn(at: columnIndex, with: updatedColumn)
//        print("update \(updatedColumn)")
    }
}

private func process(_ map: Map) throws -> Int {
    try tiltVertically(map, direction: .north)
    return northBearingWeight(map)
}

func day14_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day14_2023_example").getLines()
    let map = try Map(mapString: lines)
    return try process(map)
}

// MARK: - Part 2

private enum Direction: CaseIterable {
    case north
    case west
    case south
    case east

    var next: Direction {
        guard let index = Self.allCases.firstIndex(of: self) else {
            return .north
        }
        return Self.allCases[(index + 1) % Self.allCases.count]
    }
}

private func tiltHorizontally(_ map: Map, direction: Direction) throws {
    guard direction == .west || direction == .east else { throw AoCError.wrongFormat }
    let addBallFirst = direction == .west
    (0..<map.yCount).forEach { rowIndex in
        let row = map.rows[rowIndex].nodes
//        print("row \(row)")
        var slices = row.components(separatedBy: .cube)
        slices = slices.map { slice in
            let ballCount = slice.filter { $0 == .ball } .count
            var updatedSlice = Array(repeating: Map.Node.ball, count: ballCount)
            var leftover = Array(repeating: Map.Node.empty, count: slice.count - ballCount)
            if addBallFirst {
                updatedSlice.append(contentsOf: leftover)
                return updatedSlice
            } else {
                leftover.append(contentsOf: updatedSlice)
                return leftover
            }
        }
        var updatedRow = slices.joined(separator: .cube)
        while updatedRow.count < row.count {
            updatedRow.append(.cube)
        }
        map.rows[rowIndex] = Map.Row(nodes: updatedRow)
//        print("update \(updatedRow)")
    }
}


private func tilt(map: Map, direction: Direction) throws {
    switch direction {
    case .north, .south:
        try tiltVertically(map, direction: direction)
    case .west, .east:
        try tiltHorizontally(map, direction: direction)
    }
}


func day14_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day14_2023_input").getLines()
    let map = try Map(mapString: lines)
    var stepCount = 1
    var memoization = [String: Int]()
    let stepTarget = 1_000_000_000
    var lookingForCycle = true
    var result = 0
    while stepCount <= stepTarget {
        print("stepCount: \(stepCount)")
        try tilt(map: map, direction: .north)
        try tilt(map: map, direction: .west)
        try tilt(map: map, direction: .south)
        try tilt(map: map, direction: .east)
        if lookingForCycle, let cycleFound = memoization[map.description] {
            print(cycleFound)
            let length = stepCount - cycleFound
//            print("length: \(length)")
            // ignore looping cycles:
            let leftOver = (stepTarget - stepCount) % length
            stepCount = stepTarget - leftOver + 1
            print("updatedStepCount: \(stepCount)")
            lookingForCycle = false
        } else {
//            print(map)
//            print("bearing: \(northBearingWeight(map))")
//            print("\n")
            if lookingForCycle {
                memoization[map.description] = stepCount
            }
            stepCount += 1
        }
    }
    return northBearingWeight(map)
}
