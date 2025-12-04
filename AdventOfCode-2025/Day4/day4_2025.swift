//
//  day1_2025.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2025.
//

import Foundation

private enum Value: String {
    case empty = "."
    case roll = "@"
}

private class Cell: CustomDebugStringConvertible {
    var value: Value

    init(value: String) {
        self.value = Value(rawValue: value)!
    }

    var debugDescription: String {
        return "\(value.rawValue)"
    }
}

private class Map {
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

    subscript(tuple: (x: Int, y: Int)) -> Cell? {
        self[tuple.x, tuple.y]
    }

    func countAccessibleCells() -> Int {
        var count = 0
        for i in 0...maxX {
            for j in 0...maxY {
                count += isCellAccessible(i, j) ? 1 : 0
            }
        }
        return count
    }

    func isCellAccessible(_ x: Int, _ y: Int) -> Bool {
        guard let cell = self[x, y],
              cell.value == .roll else {
            return false
        }
        var count = 0
        Direction.allCases.forEach {
            guard count <= 4 else { return }
            if let nextCell = self[newPosition(from: (x, y), direction: $0)],
               nextCell.value == .roll {
                count += 1
            }
        }
        return count <= 3
    }

    private func newPosition(from position: (Int, Int), direction: Direction) -> (Int, Int) {
        switch direction {
        case .top:
            return (position.0, position.1 - 1)
        case .topLeft:
            return (position.0 - 1, position.1 - 1)
        case .left:
            return (position.0 - 1, position.1)
        case .downLeft:
            return (position.0 - 1, position.1 + 1)
        case .down:
            return (position.0, position.1 + 1)
        case .downRight:
            return (position.0 + 1, position.1 + 1)
        case .right:
            return (position.0 + 1, position.1)
        case .topRight:
            return (position.0 + 1, position.1 - 1)
        }
    }
}

private enum Direction: CaseIterable {
    case top
    case topLeft
    case left
    case downLeft
    case down
    case downRight
    case right
    case topRight
}

private func parseLines(_ lines: [String]) -> Map {
    let rows = lines.map { line in
        line.map { cell in
            let string = String(cell)
            return Cell(value: string)
        }
    }
    return Map(rows: rows)
}

func day4_2025_A() throws -> Int {
    let lines = try FileReader(filename: "day4_2025_input").getLines()
    let map = parseLines(lines)
    return map.countAccessibleCells()
}

// MARK: - Part B

extension Map {
    func iterateRemoval() -> Int {
        let mapping = mapAccessibleCells()
        mapping.forEach { tuple in
            self[tuple]?.value = .empty
        }
        return mapping.count
    }

    private func mapAccessibleCells() -> [(Int, Int)] {
        var array = [(Int, Int)]()
        for i in 0...maxX {
            for j in 0...maxY {
                guard isCellAccessible(i, j) else { continue }
                array.append((i, j))
            }
        }
        return array
    }

}

func day4_2025_B() throws -> Int {
    let lines = try FileReader(filename: "day4_2025_input").getLines()
    let map = parseLines(lines)
    var count = 0
    var next = map.iterateRemoval()
    while next != 0 {
        count += next
        next = map.iterateRemoval()
    }
    return count
}
