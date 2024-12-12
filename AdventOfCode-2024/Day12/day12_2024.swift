//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
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
    var topEdgeNumber = 0
    var leftEdgeNumber = 0
    var rightEdgeNumber = 0
    var bottomEdgeNumber = 0

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
private var plotSides: [Int: Int] = [:]
private var nextEdgeNumber: [Int: Int] = [:]

private struct Map {
    let rows: [[Cell]]

    init(rows: [[Cell]]) {
        self.rows = rows
        computePlots()
        computePerimeters()
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

//        nextEdgeNumber[plotNumber]


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

func day12_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day12_2024_input").getLines()
    _ = parseLines(lines)
    let costs = sizes.keys.map { key in
        sizes[key]! * perimeters[key]!
    }
    return costs.reduce(0, +)
}

// MARK: - Part B

func day12_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day12_2024_example").getLines()
    _ = parseLines(lines)
    let costs = sizes.keys.map { key in
        sizes[key]! * plotSides[key]!
    }
    return costs.reduce(0, +)
}
