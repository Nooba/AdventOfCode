//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation

private enum Direction: String, CaseIterable {
    case up = "^"
    case right = ">"
    case down = "v"
    case left = "<"

    var next: Direction {
        let index = Direction.allCases.firstIndex(of: self)!
        return Direction.allCases[(index + 1) % Direction.allCases.count]
    }
}

private class Cell {
    var value: String
    var isVisited: Bool

    init(value: String) {
        self.value = value
        self.isVisited = false
    }

    var isBlocked: Bool {
        return value == "#"
    }

//    var isGuard: Bool {
//        return Direction.allCases.map { $0.rawValue }.contains(value)
//    }
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

    subscript(position: (Int, Int)) -> Cell? {
        let (x, y) = position
        return rows[safe: y]?[safe: x].map { $0 }
    }

    func process(at position: (Int, Int)?) -> (Int, Int)? {
        guard let position else { return nil }
        let (x,y) = position
        guard let cell = self[x, y], let direction = Direction(rawValue: cell.value) else { return nil }
        cell.isVisited = true
        return getNextValidPosition(from: position, direction: direction)
    }

    private func getNextValidPosition(from position: (Int, Int), direction: Direction) -> (Int, Int)? {
        let (x,y) = position
        guard let cell = self[x, y] else { return nil }
        var nextDirection = direction
        var nextPosition = newPosition(from: position, direction: nextDirection)
        var newCell = self[nextPosition]
        while newCell != nil, newCell!.isBlocked {
            nextDirection = direction.next
            nextPosition = newPosition(from: position, direction: nextDirection)
            newCell = self[nextPosition]
        }
        newCell?.value = nextDirection.rawValue
        return nextPosition
    }

    private func newPosition(from position: (Int, Int), direction: Direction) -> (Int, Int) {
        switch direction {
        case .up:
            return (position.0, position.1 - 1)
        case .left:
            return (position.0 - 1, position.1)
        case .down:
            return (position.0, position.1 + 1)
        case .right:
            return (position.0 + 1, position.1)
        }
    }

    var totalVisited: Int {
        return rows.compactMap { row in
            row.filter { $0.isVisited }.count
        }.reduce(0, +)
    }
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

private func findStart(_ map: Map) -> (Int, Int) {
    var result: (Int, Int)?
    (0...(map.maxY)).forEach { y in
        guard result == nil else { return }
        (0...(map.maxX)).forEach { x in
            guard result == nil else { return }
            if map[x, y]?.value == "^" {
                result = (x, y)
            }
        }
    }
    return result!
}

private func process(_ map: Map) -> Int {
    var position: (Int, Int)? = findStart(map)
    while position != nil {
        position = map.process(at: position)
    }
    return map.totalVisited
}

func day6_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day6_2024_input").getLines()
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


func day6_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day6_2024_input").getLines()
    let map = parseLines(lines)
    return processSecondpart(map)
}
