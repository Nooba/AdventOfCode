//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation

private class Cell {
    let value: String

    init(value: String) {
        self.value = value
    }
}

private struct Map {
    let rows: [[Cell]]

    var maxX: Int {
        rows.map { $0.count }.max() ?? 0
    }

    var maxY: Int {
        return rows.count
    }

    subscript(x: Int, y: Int) -> Cell? {
        return rows[safe: y]?[safe: x].map { $0 }
    }

    func numberOfFoundXmas(at position: (Int, Int)) -> Int {
        let search = "XMAS"
        var count = 0
        Direction.allCases.forEach { direction in
            let countAtPos = find(search: search, startingAt: position, direction: direction) ? 1 : 0
            count += countAtPos
            if countAtPos > 0 {
//                print("Added at pos: \(position), for direction: \(direction)")
            }
        }
        return count
    }

    func find(search: String, startingAt position: (Int, Int), direction: Direction) -> Bool {
        let (x,y) = position
        guard let cell = self[x, y] else { return false }
        guard cell.value == String(search.first!) else { return false }
        let substring = String(search.dropFirst())
        guard !substring.isEmpty else { return true }
        return find(search: substring, startingAt: newPosition(from: position, direction: direction), direction: direction)
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

private func process(_ map: Map) -> Int {
    var result = 0
    (0...(map.maxY)).forEach { y in
        (0...(map.maxX)).forEach { x in
            result += map.numberOfFoundXmas(at: (x, y))
        }
    }
    return result
}

func day4_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day4_2024_input").getLines()
    let map = parseLines(lines)
    return process(map)
}

// MARK: - Part B

fileprivate var enabled = true

private func parseLinePartB(_ line: String) throws -> Int {
    var result = 0
    try parseRegexp(line, capturePattern: #"mul\(\d{1,3},\d{1,3}\)|do\(\)|don't\(\)"#, getAllMatches: true) { groups in
        let mapped = groups.compactMap { group -> String? in
            if group == "do()" {
                enabled = true
                return nil
            } else if group == "don't()" {
                enabled = false
                return nil
            } else if enabled {
                return group.replacingOccurrences(of: "mul(", with: "").replacingOccurrences(of: ")", with: "")
            }
            return nil
        }
        let components = mapped.map { $0.components(separatedBy: ",") }
        let values = components.map { $0.map { Int($0)! }.reduce(1, *) }
        result += values.reduce(0, +)
    }
    return result
}


func day4_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day4_2024_input").getLines()
    return try lines.map { try parseLinePartB($0) }.reduce(0, +)
}
