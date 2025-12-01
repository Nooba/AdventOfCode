//
//  day1_2025.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2025.
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
    let originalValue: String
    var value: String
    var isVisited: Bool
    // Part B
    var isLooping: Bool
    var visitedDirections: [Direction]

    init(originalValue: String,
         value: String,
         isVisited: Bool,
         isLooping: Bool,
         visitedDirections: [Direction]) {
        self.value = value
        self.isVisited = isVisited
        self.isLooping = isLooping
        self.visitedDirections = visitedDirections
        self.originalValue = originalValue
    }

    var isBlocked: Bool {
        return value == "#"
    }

//    var isGuard: Bool {
//        return Direction.allCases.map { $0.rawValue }.contains(value)
//    }

    var copy: Cell {
        return Cell(
            originalValue: originalValue,
            value: value,
            isVisited: isVisited,
            isLooping: isLooping,
            visitedDirections: visitedDirections
        )
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
            return Cell(originalValue: string, value: string, isVisited: false, isLooping: false, visitedDirections: [])
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

func day6_2025_A() throws -> Int {
    let lines = try FileReader(filename: "day6_2025_input").getLines()
    let map = parseLines(lines)
    return process(map)
}

// MARK: - Part B

private extension Map {
    func processSecondPart(at position: (Int, Int)?) -> (Int, Int)? {
        guard let position else {
            return nil
        }
        let (x,y) = position
        guard let cell = self[x, y], let direction = Direction(rawValue: cell.value) else {
            return nil
        }
        return getNextValidPositionSecondPart(from: position, direction: direction)
    }

    private func getNextValidPositionSecondPart(from position: (Int, Int), direction: Direction) -> (Int, Int)? {
        var nextDirection = direction
        var nextPosition = newPosition(from: position, direction: nextDirection)
        var newCell = self[nextPosition]
        while newCell != nil, newCell!.isBlocked {
            nextDirection = nextDirection.next
            nextPosition = newPosition(from: position, direction: nextDirection)
            newCell = self[nextPosition]
        }
        if newCell != nil, newCell!.visitedDirections.contains(nextDirection) {
            newCell?.isLooping = true
            return nil
        }
        newCell?.visitedDirections.append(nextDirection)
        newCell?.value = nextDirection.rawValue
//        print("next: \(nextPosition)")
        return nextPosition
    }

    var copy: Map {
        Map(rows: rows.map { row in
            row.map { cell in
                cell.copy
            }
        })
    }

    var isLooping: Bool {
        rows.contains { row in
            row.contains { $0.isLooping }
        }
    }
}

private func processSecondpart(_ map: Map) -> Int {
    print(process(map))
    (0...(map.maxY)).forEach { y in
        (0...(map.maxX)).forEach { x in
            map[x, y]?.value = map[x, y]?.originalValue ?? ""
        }
    }
    let initialPosition = findStart(map)
    var result = 0
    (0...(map.maxY)).forEach { y in
        print(y)
        (0...(map.maxX)).forEach { x in
//            print(map[x, y]?.value)

            if map[x, y]?.value == "." && map[x, y]?.isVisited ?? false {
//                print("testing \(x), \(y)")
                let mapCopy = map.copy
                mapCopy[x, y]?.value = "#"
                var position: (Int, Int)? = initialPosition
//                print(position)
                while position != nil {
                    position = mapCopy.processSecondPart(at: position)
                }
                if mapCopy.isLooping {
//                    print("found looping in \(x), \(y)")
                    result += 1
                }
            }
        }
    }
    return result
}


func day6_2025_B() throws -> Int {
    let lines = try FileReader(filename: "day6_2025_input").getLines()
    let map = parseLines(lines)
    return processSecondpart(map)
}
