//
//  day1_2025.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2025.
//

import Foundation

private enum Value: String {
    case start = "S"
    case empty = "."
    case splitter = "^"
    case beam = "|"
}

private class Cell: CustomDebugStringConvertible {
    var value: Value
    var count: Int = 0

    init(value: String) {
        self.value = Value(rawValue: value)!
        if self.value == .start {
            count = 1
        }
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

    func newPosition(from position: (Int, Int), direction: Direction) -> (Int, Int) {
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

func day7_2025_A() throws -> Int {
    let lines = try FileReader(filename: "day7_2025_input").getLines()
    let map = parseLines(lines)
    var splitCount = 0
    for j in 0..<map.maxY {
        for i in 0..<map.maxX {
            let cell = map[i, j]!
            let topCell = map[map.newPosition(from: (i, j), direction: .top)]
            switch cell.value {
            case .start:
                break
            case .splitter:
                if let topCell, topCell.value == .start || topCell.value == .beam {
                    var didSplit = false
                    let leftCell = map[map.newPosition(from: (i, j), direction: .left)]
                    if leftCell?.value == .empty {
                        didSplit = true
                        leftCell?.value = .beam
                    }
                    let rightCell = map[map.newPosition(from: (i, j), direction: .right)]
                    if rightCell?.value == .empty {
                        didSplit = true
                        rightCell?.value = .beam
                    }
                    if didSplit {
                        splitCount += 1
                    }
                }
                break
            case .empty:
                if let topCell, topCell.value == .start || topCell.value == .beam {
                    cell.value = .beam
                }
                break
            case .beam:
                break
            }
        }
    }
    return splitCount
}

// MARK: - Part B

func day7_2025_B() throws -> Int {
    let lines = try FileReader(filename: "day7_2025_input").getLines()
    let map = parseLines(lines)
    for j in 0..<map.maxY {
        for i in 0..<map.maxX {
            let cell = map[i, j]!
            let topCell = map[map.newPosition(from: (i, j), direction: .top)]
            switch cell.value {
            case .start:
                break
            case .splitter:
                if let topCell, topCell.value == .start || topCell.value == .beam {
                    let leftCell = map[map.newPosition(from: (i, j), direction: .left)]
                    if leftCell?.value == .empty || leftCell?.value == .beam {
                        leftCell?.value = .beam
                        leftCell?.count += topCell.count
                    }
                    let rightCell = map[map.newPosition(from: (i, j), direction: .right)]
                    if rightCell?.value == .empty || rightCell?.value == .beam {
                        rightCell?.value = .beam
                        rightCell?.count += topCell.count
                    }
                }
                break
            case .empty:
                if let topCell, topCell.value == .start || topCell.value == .beam {
                    cell.value = .beam
                    cell.count += topCell.count
                }
                break
            case .beam:
                if let topCell, topCell.value == .beam {
                    cell.count += topCell.count
                    break
                }
            }
        }
    }
//    print(map.rows.last!.map { $0.count} )
    return map.rows.last!.reduce(into: 0) { partialResult, cell in
        partialResult += cell.count
    }
}

//    .......S.......
//    .......1........
//    ......1^1......
//    ...............
//    .....1^2^1.....
//    ...............
//    ....1^3^3^1....
//    ...............
//    ...1^4^331^1...
//    ...............
//    ..1^5^434^2^1..
//    ...............
//    .1^154^74.21^1.
//    ...............
//    1^2^A^B^B^211^1
//    ...............
//
