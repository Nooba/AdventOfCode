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

extension Map {
    func isXCrossesMas(at position: (Int, Int)) -> Bool {
        let (x,y) = position
        guard let cell = self[x, y] else { return false }
        guard cell.value == "A" else { return false }
        guard
            let topLeft = self[x - 1, y - 1],
            let topRight = self[x + 1, y - 1],
            let downLeft = self[x - 1, y + 1],
            let downRight = self[x + 1, y + 1],
            [topLeft, topRight, downLeft, downRight].allSatisfy ({ $0.value == "M" || $0.value == "S" }) else {
                return false
            }
        if (topLeft.value == "M"
            && topRight.value == "M"
            && downLeft.value == "S"
            && downRight.value == "S") {
            // M - S
            // - A -
            // M - S
            return true
        }
        if (topLeft.value == "M"
            && topRight.value == "S"
            && downLeft.value == "M"
            && downRight.value == "S") {
            // M - M
            // - A -
            // S - S
            return true
        }
        if (topLeft.value == "S"
            && topRight.value == "S"
            && downLeft.value == "M"
            && downRight.value == "M") {
            // S - M
            // - A -
            // S - M
            return true
        }
        if (topLeft.value == "S"
            && topRight.value == "M"
            && downLeft.value == "S"
            && downRight.value == "M") {
            // S - M
            // - A -
            // S - M
            return true
        }
        return false
    }
}

private func processSecondpart(_ map: Map) -> Int {
    var result = 0
    (0...(map.maxY)).forEach { y in
        (0...(map.maxX)).forEach { x in
            let isCross = map.isXCrossesMas(at: (x, y))
            result += isCross ? 1 : 0
            if isCross {
//                print("cross at :\(x), \(y)")
            }
        }
    }
    return result
}


func day4_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day4_2024_input").getLines()
    let map = parseLines(lines)
    return processSecondpart(map)
}
