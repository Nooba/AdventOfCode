//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation
import Algorithms

private enum Direction {
    case up
    case down
    case left
    case right
}

private class Cell {
    let value: Int
    var directions: [Direction] = []

    init(value: Int) {
        self.value = value
    }
}

private struct Position: Hashable {
    let x: Int
    let y: Int
}

private struct Map {
    let rows: [[Cell]]

    init(rows: [[Cell]]) {
        self.rows = rows
        computeDirections()
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

    func computeTrailheadScore(at position: Position) -> Int {
        guard let cell = self[position], cell.value == 0 else { return 0 }
//        print("\ncell: \(cell.value) at \(position)")
        let walks = cell.directions.map { direction in
            walk(from: position, direction: direction)
        }.flatMap { $0 }
        return Set(walks).count
    }

    func walk(from position: Position, direction: Direction) -> [Position] {
        var newPosition: Position
        switch direction {
        case .up:
            newPosition = Position(x: position.x, y: position.y - 1)
        case .down:
            newPosition = Position(x: position.x, y: position.y + 1)
        case .left:
            newPosition = Position(x: position.x - 1, y: position.y)
        case .right:
            newPosition = Position(x: position.x + 1, y: position.y)
        }
        guard let nextCell = self[newPosition] else { return [] }
//        print("nextCell: \(nextCell.value) at \(newPosition)")
        if nextCell.value == 9 { return [newPosition] }
        return nextCell.directions
            .map { walk(from: newPosition, direction: $0) }
            .flatMap { $0 }
    }

    // MARK: - Private

    private func computeDirections() {
        (0...(maxY)).forEach { y in
            (0...(maxX)).forEach { x in
                computeDirections(at: Position(x: x, y: y))
            }
        }
    }

    private func computeDirections(at position: Position) {
        guard let cell = self[position] else { return }
        var directions = [Direction]()
        if cellAbove(position: position)?.value == cell.value + 1 {
            directions.append(.up)
        }
        if cellBelow(position: position)?.value == cell.value + 1 {
            directions.append(.down)
        }
        if cellLeft(position: position)?.value == cell.value + 1 {
            directions.append(.left)
        }
        if cellRight(position: position)?.value == cell.value + 1 {
            directions.append(.right)
        }
        cell.directions = directions
    }

    private func cellAbove(position: Position) -> Cell? {
        return self[position.x, position.y - 1]
    }

    private func cellBelow(position: Position) -> Cell? {
        return self[position.x, position.y + 1]
    }

    private func cellLeft(position: Position) -> Cell? {
        return self[position.x - 1, position.y]
    }

    private func cellRight(position: Position) -> Cell? {
        return self[position.x + 1, position.y]
    }
}

private func parseLines(_ lines: [String]) -> Map {
    let rows = lines.map { line in
        line.map { cell in
            return Cell(value: Int(String(cell))!)
        }
    }
    return Map(rows: rows)
}

private func process(_ map: Map) {
}

func day10_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day10_2024_input").getLines()
    let map = parseLines(lines)
    var results = [Int]()
    (0...(map.maxY)).forEach { y in
        (0...(map.maxX)).forEach { x in
            results.append(map.computeTrailheadScore(at: Position(x: x, y: y)))
        }
    }
    return results.reduce(0, +)
}

// MARK: - Part B

func day10_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day10_2024_input").getLines()
    let map = parseLines(lines)
    return -1
}
