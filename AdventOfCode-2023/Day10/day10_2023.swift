//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private enum Pipe: String {
    case vertical = "|"
    case horizontal = "-"
    case NE = "L"
    case NW = "J"
    case SE = "F"
    case SW = "7"

    var goesDown: Bool {
        switch self {
        case .vertical, .SW, .SE:
            return true
        default:
            return false
        }
    }

    var goesLeft: Bool {
        switch self {
        case .horizontal, .NW, .SW:
            return true
        default:
            return false
        }
    }

    var goesRight: Bool {
        switch self {
        case .horizontal, .NE, .SE:
            return true
        default:
            return false
        }
    }

    var goesTop: Bool {
        switch self {
        case .vertical, .NE, .NW:
            return true
        default:
            return false
        }
    }
}

private class Node: Equatable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.type == rhs.type
        && lhs.distance == rhs.distance
    }
    
    enum NodeType: Equatable {
        case ground
        case pipe(Pipe)
        case start
    }

    let type: NodeType
    var distance = -1

    init(string: String) throws {
        switch string {
        case ".":
            self.type = .ground
        case "S":
            self.type = .start
        default:
            guard let pipe = Pipe(rawValue: string) else {
                throw AoCError.wrongFormat
            }
            self.type = .pipe(pipe)
        }
    }

    var stringValue: String {
        switch self.type {
        case .ground:
            return "."
        case .pipe(let pipe):
            return pipe.rawValue
        case .start:
            return "S"
        }
    }

    var distanceValue: String {
        switch self.type {
        case .ground:
            return "."
        case .pipe(_):
            return "\(distance)"
        case .start:
            return "S"
        }
    }

    var goesDown: Bool {
        switch self.type {
        case .pipe(let pipe):
            return pipe.goesDown
        default:
            return false
        }
    }

    var goesLeft: Bool {
        switch self.type {
        case .pipe(let pipe):
            return pipe.goesLeft
        default:
            return false
        }
    }

    var goesRight: Bool {
        switch self.type {
        case .pipe(let pipe):
            return pipe.goesRight
        default:
            return false
        }
    }

    var goesTop: Bool {
        switch self.type {
        case .pipe(let pipe):
            return pipe.goesTop
        default:
            return false
        } 
    }

    var pipe: Pipe? {
        switch self.type {
        case .ground, .start:
            return nil
        case .pipe(let pipe):
            return pipe
        }
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
            return row.nodes.map { $0.stringValue }.joined()
        }.joined(separator: "\n")
    }

    var distanceMap: String {
        return rows.map { row in
            return row.nodes.map { $0.distanceValue }.joined()
        }.joined(separator: "\n")
    }

    subscript(y: Int) -> Row? {
        rows[safe: y]
    }

    subscript(position: (Int, Int)) -> Node? {
        self[position.1]?[position.0]
    }
}

private func parseLine(_ line: String) -> [Int] {
    return line.components(separatedBy: .whitespaces).compactMap { Int($0) }
}

private func findAccessiblesNodesFromOrigin(_ map: Map, origin: (Int, Int)) -> [(Int, Int)] {
    let top = (origin.0, origin.1 - 1)
    let left = (origin.0 - 1, origin.1)
    let right = (origin.0 + 1, origin.1)
    let bottom = (origin.0, origin.1 + 1)
    var found: [(Int, Int)] = []
    if let topNode = map[top.1]?[top.0], topNode.goesDown {
        found.append(top)
    }
    if let bottomNode = map[bottom.1]?[bottom.0], bottomNode.goesTop {
        found.append(bottom)
    }
    if let rightNode = map[right.1]?[right.0], rightNode.goesRight {
        found.append(right)
    }
    if let leftNode = map[left.1]?[left.0], leftNode.goesLeft {
        found.append(left)
    }
    return found
}

private func nextNodePosition(previousPosition: (Int, Int), currentPosition: (Int, Int), pipe: Pipe) -> (Int, Int) {
    switch pipe {
    case .horizontal:
        if previousPosition.0 < currentPosition.0 {
            return (currentPosition.0 + 1, currentPosition.1)
        }
        return (currentPosition.0 - 1, currentPosition.1)
    case .vertical:
        if previousPosition.1 < currentPosition.1 {
            return (currentPosition.0, currentPosition.1 + 1)
        }
        return (currentPosition.0, currentPosition.1 - 1)
    case .NE:
        if previousPosition.0 > currentPosition.0 {
            return (currentPosition.0, currentPosition.1 - 1)
        }
        return (currentPosition.0 + 1, currentPosition.1)
    case .NW:
        if previousPosition.0 < currentPosition.0 {
            return (currentPosition.0, currentPosition.1 - 1)
        }
        return (currentPosition.0 - 1, currentPosition.1)
    case .SE:
        if previousPosition.0 > currentPosition.0 {
            return (currentPosition.0, currentPosition.1 + 1)
        }
        return (currentPosition.0 + 1, currentPosition.1)
    case .SW:
        if previousPosition.0 < currentPosition.0 {
            return (currentPosition.0, currentPosition.1 + 1)
        }
        return (currentPosition.0 - 1, currentPosition.1)
    }
}

private func process(map: Map) -> Int {
    var (rowStartIndex, columnStartIndex) = (-1, -1)
    columnStartIndex = map.rows.firstIndex { row in
        let found = row.nodes.firstIndex { $0.type == .start }
        if let found { rowStartIndex = found }
        return found != nil
    }!
    let starts = findAccessiblesNodesFromOrigin(map, origin: (rowStartIndex, columnStartIndex))
    var processDone = false
    var currentDistance = 1
    var previousLeft = (rowStartIndex, columnStartIndex)
    var previousRight = (rowStartIndex, columnStartIndex)
    var currentLeft = starts.first!
    var currentRight = starts.last!
    while !processDone {
        let leftNode = map[currentLeft]!
        let rightNode = map[currentRight]!
        if leftNode.distance != -1 || rightNode.distance != -1 {
            processDone = true
            break
        }
        leftNode.distance = currentDistance
        rightNode.distance = currentDistance
        let nextLeft = nextNodePosition(
            previousPosition: previousLeft,
            currentPosition: currentLeft,
            pipe: map[currentLeft]!.pipe!
        )
        let nextRight = nextNodePosition(
            previousPosition: previousRight,
            currentPosition: currentRight,
            pipe: map[currentRight]!.pipe!
        )
        previousLeft = currentLeft
        currentLeft = nextLeft
        previousRight = currentRight
        currentRight = nextRight
        currentDistance += 1
    }
//    print(map.distanceMap)
    return currentDistance - 1
}

func day10_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day10_2023_input").getLines()
    let map = try Map(rowsString: lines)
    return process(map: map)
}

// MARK: - Part 2

private func parseLineSecondPart(_ line: String) -> [Int] {
    return parseLine(line).reversed()
}

func day10_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day10_2023_input").getLines()
    let inputs = lines.map(parseLineSecondPart(_:))
    return -1
}
