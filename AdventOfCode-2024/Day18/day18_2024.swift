//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation

private struct Position: CustomStringConvertible {
    let x: Int
    let y: Int

    var description: String {
        return "\(x), \(y)"
    }

    var above: Position { Position(x: x, y: y-1) }
    var below: Position { Position(x: x, y: y+1) }
    var left: Position { Position(x: x-1, y: y) }
    var right: Position { Position(x: x+1, y: y) }
}

private enum Direction: String, CaseIterable {
    case up = "^"
    case left = "<"
    case right = ">"
    case down = "v"

    var opposite: Direction {
        switch self {
        case .up:
            return .down
        case .left:
            return .right
        case .right:
            return .left
        case .down:
            return .up
        }
    }
}

private class Cell: CustomStringConvertible {
    var isCorrupted = false
    var cost: Int

    init(isCorrupted: Bool = false, cost: Int) {
        self.isCorrupted = isCorrupted
        self.cost = cost
    }

    var description: String {
        return isCorrupted ? "#" : "."
    }
}

private struct Map: CustomStringConvertible {

    var description: String {
        return rows.map { row in
            return row.map { $0.description }.joined()
        }.joined(separator: "\n")
    }

    let rows: [[Cell]]

    init(rows: [[Cell]]) {
        self.rows = rows
    }

    var maxX: Int {
        rows.map { $0.count }.max() ?? 0
    }

    var maxY: Int {
        return rows.count
    }

    subscript(x: Int, y: Int) -> Cell? {
        return rows[safe: y]?[safe: x].map { $0 }
    }

    subscript(position: Position) -> Cell? {
        self[position.x, position.y]
    }
}

private func parseMap(_ lines: [String], corruptedCount: Int) throws -> Map {
//    let (size, corruptedCount) = (7, 12) // Example
    let (size) = (71)
    let rows = (0..<size).map { y in
        (0..<size).map { x in
            return Cell(cost: 0)
        }
    }
    let map = Map(rows: rows)
//    print(map)
    lines.prefix(corruptedCount).forEach { line in
        let components = line.components(separatedBy: ",").map { Int($0)! }
        let position = Position(x: components[0], y: components[1])
        map[position]?.isCorrupted = true
    }
    return map
}

private extension Map {

}

private extension Map {
    func computeCosts() -> Int {
        let origin = Position(x: 0, y: 0)
        var cellsToPropagateFrom = [origin]
        self[origin]?.cost = 0
        while !cellsToPropagateFrom.isEmpty {
            let nextCells = cellsToPropagateFrom.flatMap { cell in
                propagate(from: cell)
            }
            cellsToPropagateFrom = nextCells
//            print(self)
        }
        return self[Position(x: 70, y: 70)]!.cost
    }

    // MARK: - Private

    private func propagate(from origin: Position) -> [Position] {
        guard let cell = self[origin] else { return [] }
        var nextCells = [Position]()
        let newCost = cell.cost + 1
        Direction.allCases.forEach { direction in
            switch direction {
            case .left:
                if let leftCell = self[origin.left], !leftCell.isCorrupted {
                    if newCost < leftCell.cost || leftCell.cost == 0 {
                        leftCell.cost = newCost
                        nextCells.append(origin.left)
                    }
                }
            case .right:
                if let rightCell = self[origin.right], !rightCell.isCorrupted {
                    if newCost < rightCell.cost || rightCell.cost == 0 {
                        rightCell.cost = newCost
                        nextCells.append(origin.right)
                    }
                }
            case .up:
                if let upCell = self[origin.above], !upCell.isCorrupted {
                    if newCost < upCell.cost || upCell.cost == 0 {
                        upCell.cost = newCost
                        nextCells.append(origin.above)
                    }
                }

            case .down:
                if let downCell = self[origin.below], !downCell.isCorrupted {
                    if newCost < downCell.cost || downCell.cost == 0 {
                        downCell.cost = newCost
                        nextCells.append(origin.below)
                    }
                }
            }
        }
        return nextCells
    }
}

func day18_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day18_2024_input").getLines()
    let map = try parseMap(lines, corruptedCount: 1024)
    print(map)
    let result = map.computeCosts()
    return result
}

// MARK: - Part B

func day18_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day18_2024_input").getLines()
    let totalStep = lines.count
    var knownGoodStep = 0
    var knownBadStep = totalStep
    var currentStep = totalStep

    while true {
//        print(currentStep)
        let map = try parseMap(lines, corruptedCount: currentStep)
        let currentCost = map.computeCosts()
        var nextStep = 0
        if currentCost == 0 {
            knownBadStep = min(knownBadStep, currentStep)
        } else {
            knownGoodStep = max(knownGoodStep, currentStep)
        }
        nextStep = (knownBadStep + knownGoodStep) / 2
        if nextStep == currentStep {
            let result = currentStep
            print(lines[result])
            return result
        }
        currentStep = nextStep
    }
    return -1
}
