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

    enum Status {
        case unknown
        case outside
        case inside
        case limit
    }

    let type: NodeType
    var distance = -1
    var status: Status = .unknown

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
            self.status = .limit
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
        case .pipe(_), .start:
            return distance == -1 ? "!" : "?"
//            return "\(distance)"
        }
    }

    var part2Map: String {
        distance == -2 ? "I" : "."
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

    var part2Map: String {
        return rows.map { row in
            return row.nodes.map { $0.part2Map }.joined()
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
    map[(rowStartIndex, columnStartIndex)]?.distance = 0
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

private func processNest(_ map: Map) -> Int {
//    (0..<map.rows.count).forEach { yIndex in
//        (0..<map.rows[0].nodes.count).forEach { xIndex in
//            print((xIndex, yIndex))
    computeNestNode(position: (0, 0), map: map)
//        }
//    }
    return map.rows.map { $0.nodes.filter { $0.distance == -1 }.count }.reduce(0, +)
}


private func computeNestNode(position: (Int, Int), map: Map) {
    guard let currentNode = map[position], currentNode.distance == -1 else {
        return
    }
    currentNode.distance = -2
    let topPosition = (position.0, position.1 - 1)
    computeNestNode(position: topPosition, map: map)
    let leftPosition = (position.0 - 1, position.1)
    computeNestNode(position: leftPosition, map: map)
    let bottomPosition = (position.0, position.1 + 1)
    computeNestNode(position: bottomPosition, map: map)
    let rightPosition = (position.0 + 1, position.1)
    computeNestNode(position: rightPosition, map: map)
}

private enum Direction {
    case top
    case bottom
    case left
    case right
}

private func processSecondPart(_ map: Map) -> Int {
    (0..<map.rows.count).forEach { yIndex in
        (0..<map.rows[0].nodes.count).forEach { xIndex in
            let currentNode = map[(xIndex, yIndex)]!
            guard currentNode.type == .ground else {
                return
            }
            let leftPipesCount = (0..<xIndex).map { map[($0, yIndex)] }.compactMap { $0 }.filter { $0.distance >= 0 }.count
            let topPipesCount = (0..<yIndex).map { map[(xIndex, $0)] }.compactMap { $0 }.filter { $0.distance >= 0 }.count
            if leftPipesCount % 2 == 1 && topPipesCount % 2 == 1 {
                currentNode.distance = -2
            }
        }
    }
    print(map.part2Map)
    return map.rows.map { $0.nodes.filter { $0.distance == -2 }.count }.reduce(0, +)
}

func day10_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day10_2023_example").getLines()
    let map = try Map(rowsString: lines)
    _ = process(map: map)
    return processSecondPart(map)
}

// Current issue:  We need to take into account the following
/**
 In fact, there doesn't even need to be a full tile path to the outside for tiles to count as outside the loop - squeezing between pipes is also allowed! Here, I is still within the loop and O is still outside the loop:
 */
