//
//  day1_2025.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2025.
//

import Foundation
import Algorithms

private enum Direction: CaseIterable {
    case up
    case down
    case left
    case right
}

private class Cell: CustomDebugStringConvertible {
    let value: String
    var plotNumber = 0
    var topEdgeNumber = -1
    var leftEdgeNumber = -1
    var rightEdgeNumber = -1
    var bottomEdgeNumber = -1

    init(value: String) {
        self.value = value
    }

    var debugDescription: String {
        return "\(plotNumber)"
    }
}

private struct Position: Hashable {
    let x: Int
    let y: Int
}

private var sizes: [Int: Int] = [:]
private var perimeters: [Int: Int] = [:]
private var nextEdgeNumber: [Int: Int] = [:]

private struct Map {
    let rows: [[Cell]]

    init(rows: [[Cell]]) {
        self.rows = rows
        computePlots()
        computePerimeters()
        computeEdges()
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



    // MARK: - Private

    private func computePlots() {
        var plotNumber = 1
        (0...(maxY)).forEach { y in
            (0...(maxX)).forEach { x in
                plotNumber = computePlots(at: Position(x: x, y: y), assignPlotNumber: plotNumber)
            }
        }
    }

    private func computePlots(at position: Position, assignPlotNumber plotNumber: Int) -> Int {
        guard let cell = self[position], cell.plotNumber == 0 else { return plotNumber }

        cell.plotNumber = plotNumber
        sizes[plotNumber] = (sizes[plotNumber] ?? 0) + 1
        Direction.allCases.forEach { direction in
            let newPosition = newPosition(from: position, direction: direction)
            let nextCell = self[newPosition]
            if cell.value == nextCell?.value {
                _ = computePlots(at: newPosition, assignPlotNumber: plotNumber)
            }
        }
        return plotNumber + 1
    }

    private func updateEdgeNumber(at position: Position) {
        guard let cell = self[position] else { return }
        var nextEdge = nextEdgeNumber[cell.plotNumber] ?? 0
        var leftCell: Cell?
        if let left = cellLeft(position: position), left.plotNumber == cell.plotNumber {
            leftCell = left
        }
        var rightCell: Cell?
        if let right = cellRight(position: position), right.plotNumber == cell.plotNumber {
            rightCell = right
        }

        var aboveCell: Cell?
        if let above = cellAbove(position: position), above.plotNumber == cell.plotNumber {
            aboveCell = above
        }
        var belowCell: Cell?
        if let below = cellBelow(position: position), below.plotNumber == cell.plotNumber {
            belowCell = below
        }

        if cell.topEdgeNumber == -1 && aboveCell == nil {
            if leftCell != nil, leftCell?.topEdgeNumber != -1 {
                cell.topEdgeNumber = leftCell!.topEdgeNumber
            } else if rightCell != nil, rightCell?.topEdgeNumber != -1 {
                cell.topEdgeNumber = rightCell!.topEdgeNumber
            } else if aboveCell == nil || aboveCell?.plotNumber != cell.plotNumber {
                cell.topEdgeNumber = nextEdge
                nextEdge += 1
                nextEdgeNumber[cell.plotNumber] = nextEdge
            }
        }
        if cell.bottomEdgeNumber == -1 && belowCell == nil {
            if leftCell != nil, leftCell?.bottomEdgeNumber != -1 {
                cell.bottomEdgeNumber = leftCell!.bottomEdgeNumber
            } else if rightCell != nil, rightCell?.bottomEdgeNumber != -1 {
                cell.bottomEdgeNumber = rightCell!.bottomEdgeNumber
            } else if belowCell == nil || belowCell?.plotNumber != cell.plotNumber {
                cell.bottomEdgeNumber = nextEdge
                nextEdge += 1
                nextEdgeNumber[cell.plotNumber] = nextEdge
            }
        }
        if cell.leftEdgeNumber == -1 && leftCell == nil {
            if aboveCell != nil, aboveCell?.leftEdgeNumber != -1 {
                cell.leftEdgeNumber = aboveCell!.leftEdgeNumber
            } else if belowCell != nil, belowCell?.leftEdgeNumber != -1 {
                cell.leftEdgeNumber = belowCell!.leftEdgeNumber
            } else if leftCell == nil || leftCell?.plotNumber != cell.plotNumber  {
                cell.leftEdgeNumber = nextEdge
                nextEdge += 1
                nextEdgeNumber[cell.plotNumber] = nextEdge
            }
        }
        if cell.rightEdgeNumber == -1 && rightCell == nil {
            if aboveCell != nil, aboveCell?.rightEdgeNumber != -1 {
                cell.rightEdgeNumber = aboveCell!.rightEdgeNumber
            } else if belowCell != nil, belowCell?.rightEdgeNumber != -1 {
                cell.rightEdgeNumber = belowCell!.rightEdgeNumber
            } else if rightCell == nil || rightCell?.plotNumber != cell.plotNumber {
                cell.rightEdgeNumber = nextEdge
                nextEdge += 1
                nextEdgeNumber[cell.plotNumber] = nextEdge
            }
        }
    }

    private func cellAbove(position: Position) -> Cell? {
        return self[newPosition(from: position, direction: .up)]
    }

    private func cellBelow(position: Position) -> Cell? {
        return self[newPosition(from: position, direction: .down)]
    }

    private func cellLeft(position: Position) -> Cell? {
        return self[position.x - 1, position.y]
    }

    private func cellRight(position: Position) -> Cell? {
        return self[position.x + 1, position.y]
    }

    private func newPosition(from position: Position, direction: Direction) -> Position {
        switch direction {
        case .up:
            return Position(x: position.x, y: position.y - 1)
        case .down:
            return Position(x: position.x, y: position.y + 1)
        case .left:
            return Position(x: position.x - 1, y: position.y)
        case .right:
            return Position(x: position.x + 1, y: position.y)
        }
    }

    private func computePerimeters() {
        (0...(maxY)).forEach { y in
            (0...(maxX)).forEach { x in
                computePerimeter(at: Position(x: x, y: y))
            }
        }
    }

    private func computePerimeter(at position: Position) {
        guard let cell = self[position] else { return }
        let plotNumber = cell.plotNumber
        var perimeter = 4
        Direction.allCases.forEach { direction in
            let newPosition = newPosition(from: position, direction: direction)
            let nextCell = self[newPosition]
            if cell.plotNumber == nextCell?.plotNumber {
                perimeter -= 1
            }
        }
        perimeters[plotNumber] = (perimeters[plotNumber] ?? 0) + perimeter
    }

    private func computeEdges() {
        (0...(maxY)).forEach { y in
            (0...(maxX)).forEach { x in
                updateEdgeNumber(at: Position(x: x, y: y))
            }
        }
    }
}

private func parseLines(_ lines: [String]) -> Map {
    let rows = lines.map { line in
        line.map { cell in
            return Cell(value: String(cell))
        }
    }
    return Map(rows: rows)
}

private func process(_ map: Map) {
}

func day12_2025_A() throws -> Int {
    let lines = try FileReader(filename: "day12_2025_input").getLines()
    _ = parseLines(lines)
    let costs = sizes.keys.map { key in
        sizes[key]! * perimeters[key]!
    }
    return costs.reduce(0, +)
}

// MARK: - Part B

func day12_2025_B() throws -> Int {
    let lines = try FileReader(filename: "day12_2025_input").getLines()
    _ = parseLines(lines)
    let costs = sizes.keys.map { key in
        sizes[key]! * nextEdgeNumber[key]!
    }
    return costs.reduce(0, +)
}
