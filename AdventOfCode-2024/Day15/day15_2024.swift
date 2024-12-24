//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation

private struct Position: CustomStringConvertible, Hashable {
    let x: Int
    let y: Int

    var description: String {
        return "(\(x), \(y))"
    }

    var above: Position { Position(x: x, y: y-1) }
    var below: Position { Position(x: x, y: y+1) }
    var left: Position { Position(x: x-1, y: y) }
    var right: Position { Position(x: x+1, y: y) }
}

private enum Direction: String {
    case up = "^"
    case left = "<"
    case right = ">"
    case down = "v"
}

private enum Object: String {
    case wall = "#"
    case empty = "."
    case box = "O"
    case robot = "@"
    case leftBox = "["
    case rightBox = "]"
}

private class Cell: CustomStringConvertible {
    var value: Object

    init(value: Object) {
        self.value = value
    }

    var isEmpty: Bool {
        value == .empty
    }

    var isWall: Bool {
        value == .wall
    }

    var isBox: Bool {
        value == .box
    }

    var isLeftBox: Bool {
        value == .leftBox
    }

    var isRightBox: Bool {
        value == .rightBox
    }

    var isRobot: Bool {
        value == .robot
    }

    var description: String {
        return value.rawValue
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

    var robot: Position {
        let position = rows.enumerated().compactMap { iterator in
            let (y, row) = iterator
            return row.enumerated().compactMap { rowIterator in
                let (x, cell) = rowIterator
                if cell.isRobot { return Position(x: x, y: y) }
                return nil
            }.first
        }.first
        return position!
    }

    func findEmptySpace(from position: Position, inDirection direction: Direction) -> Position? {
        switch direction {
        case .up:
            var y = position.y - 1
            var foundWall = false
            while y > 0, !foundWall {
                let newPosition = Position(x: position.x, y: y)
                let cell = self[newPosition]!
                if cell.isEmpty { return newPosition }
                if cell.isWall { foundWall = true }
                y -= 1
            }
            return nil
        case .left:
            var x = position.x - 1
            var foundWall = false
            while x > 0, !foundWall {
                let newPosition = Position(x: x, y: position.y)
                let cell = self[newPosition]!
                if cell.isEmpty { return newPosition }
                if cell.isWall { foundWall = true }
                x -= 1
            }
            return nil
        case .right:
            var x = position.x + 1
            var foundWall = false
            while x > 0, !foundWall {
                let newPosition = Position(x: x, y: position.y)
                let cell = self[newPosition]!
                if cell.isEmpty { return newPosition }
                if cell.isWall { foundWall = true }
                x += 1
            }
            return nil
        case .down:
            var y = position.y + 1
            var foundWall = false
            while y > 0, !foundWall {
                let newPosition = Position(x: position.x, y: y)
                let cell = self[newPosition]!
                if cell.isEmpty { return newPosition }
                if cell.isWall { foundWall = true }
                y += 1
            }
            return nil
        }
    }
}

private func parseMap(_ lines: [String]) throws -> Map {
    let rows = lines.map { line in
        line.map { cell in
            let string = String(cell)
            return Cell(value: Object(rawValue: string)!)
        }
    }
    return Map(rows: rows)
}

private func parseInstructions(_ lines: [String]) throws -> [Direction] {
    return lines.flatMap { line in
        line.map { instruction in
            return Direction(rawValue: String(instruction))!
        }
    }
}

private func apply(direction: Direction, to warehouse: Map) {
    let robot = warehouse.robot
    let emptySpace: Position? = warehouse.findEmptySpace(from: robot, inDirection: direction)
    guard let emptySpace else { return }
    switch direction {
    case .up:
        (0..<(robot.y - emptySpace.y)).forEach { y in
            warehouse[Position(x: robot.x, y: emptySpace.y + y)]!.value = warehouse[Position(x: robot.x, y: emptySpace.y + y + 1)]!.value
        }
    case .left:
        (0..<(robot.x - emptySpace.x)).forEach { x in
            warehouse[Position(x: emptySpace.x + x, y: robot.y)]!.value = warehouse[Position(x: emptySpace.x + x + 1, y: robot.y)]!.value
        }
    case .right:
        (0..<(emptySpace.x - robot.x)).forEach { x in
            warehouse[Position(x: emptySpace.x - x, y: robot.y)]!.value = warehouse[Position(x: emptySpace.x - x - 1, y: robot.y)]!.value
        }
    case .down:
        (0..<(emptySpace.y - robot.y)).forEach { y in
            let position = Position(x: robot.x, y: emptySpace.y - y)
            warehouse[position]!.value = warehouse[Position(x: robot.x, y: emptySpace.y - y - 1)]!.value
        }
    }
    warehouse[robot]?.value = .empty
}

private extension Map {
    func computeGPS() -> Int {
        return rows.enumerated().compactMap { yIterator in
            let (y, row) = yIterator
            return row.enumerated().map { xIterator in
                let (x, cell) = xIterator
                if cell.isBox {
                    return x + 100 * y
                }
                return 0
            }.reduce(0, +)
        }.reduce(0, +)
    }
}

func day15_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day15_2024_input").getGroupedLines()
    let map = try parseMap(lines[0])
    print(map)
    let instrutions = try parseInstructions(lines[1])
    instrutions.forEach { instruction in
//        print("\n\nDirection: \(instruction)\n")
        apply(direction: instruction, to: map)
//        print(map)
    }
    return map.computeGPS()
}

// MARK: - Part B

private func parseSecondPartMap(_ lines: [String]) throws -> Map {
    let rows = lines.map { line in
        line.flatMap { cell in
            let string = String(cell)
            if string == "O" {
                return [Cell(value: .leftBox), Cell(value: .rightBox)]
            } else if string == "@" {
                return [Cell(value: .robot), Cell(value: .empty)]
            } else {
                let object = Object(rawValue: string)!
                return [Cell(value: object), Cell(value: object)]
            }
        }
    }
    return Map(rows: rows)
}

private extension Map {
    func computeSecondPartGPS() -> Int {
        return rows.enumerated().compactMap { yIterator in
            let (y, row) = yIterator
            return row.enumerated().map { xIterator in
                let (x, cell) = xIterator
                if cell.isLeftBox {
                    return x + 100 * y
                }
                return 0
            }.reduce(0, +)
        }.reduce(0, +)
    }
}

func day15_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day15_2024_example").getGroupedLines()
    let warehouse = try parseSecondPartMap(lines[0])
    print(warehouse)
    let instrutions = try parseInstructions(lines[1])
    instrutions.forEach { instruction in
//        print("\n\nDirection: \(instruction)\n")
        let robot = warehouse.robot
        if warehouse.push(value: .robot, position: robot, direction: instruction) {
            warehouse[robot]?.value = .empty
        }
//        print("\n\n\(instruction)\n")
//        print(warehouse)
    }
    return warehouse.computeSecondPartGPS()
}

private extension Map {
    func push(value: Object, position: Position, direction: Direction) -> Bool {
        switch direction {
        case .up:
            pushUp(positions: [position: value])
        case .left:
            pushLeft(position: position)
        case .right:
            pushRight(position: position)
        case .down:
            pushDown(positions: [position: value])
        }
    }

    // MARK: - Private

    private func pushUp(positions: [Position: Object]) -> Bool {
        var affectedPositions = [Position: Object]()
        positions.forEach { (key, value) in
            affectedPositions[key.above] = self[key]!.value
        }
        var solvedPositions = [Position: Object]()
        let result = positions.keys.map { origin in
            guard let above = self[origin.above],
                  !above.isWall else {
                return false
            }
            if above.isLeftBox {
                if affectedPositions[origin.above.right] == nil { affectedPositions[origin.above.right] = .empty }
            } else if above.isRightBox {
                if affectedPositions[origin.above.left] == nil { affectedPositions[origin.above.left] = .empty }
            } else if above.isEmpty {
                solvedPositions[origin.above] = affectedPositions[origin.above]
                affectedPositions[origin.above] = nil
            }
            return true
        }
        guard !(result.contains { $0 == false }) else { return false }
        guard affectedPositions.isEmpty || pushUp(positions: affectedPositions) else { return false }
        solvedPositions.forEach { (key, value) in
            self[key]!.value = value
        }
        affectedPositions.forEach { (key, value) in
            self[key]!.value = value
        }
        return true
    }

    private func pushDown(positions: [Position: Object]) -> Bool {
        var affectedPositions = [Position: Object]()
        positions.forEach { (key, value) in
            affectedPositions[key.below] = self[key]!.value
        }
        var solvedPositions = [Position: Object]()
        let result = positions.keys.map { origin in
            guard let below = self[origin.below],
                  !below.isWall else {
                return false
            }
            if below.isLeftBox {
                if affectedPositions[origin.below.right] == nil { affectedPositions[origin.below.right] = .empty }
            } else if below.isRightBox {
                if affectedPositions[origin.below.left] == nil { affectedPositions[origin.below.left] = .empty }
            } else if below.isEmpty {
                solvedPositions[origin.below] = affectedPositions[origin.below]
                affectedPositions[origin.below] = nil
            }
            return true
        }
        guard !(result.contains { $0 == false }) else { return false }
        guard affectedPositions.isEmpty || pushDown(positions: affectedPositions) else { return false }
        solvedPositions.forEach { (key, value) in
            self[key]!.value = value
        }
        affectedPositions.forEach { (key, value) in
            self[key]!.value = value
        }
        return true
    }

    private func pushLeft(position: Position) -> Bool {
        let affectedPositions = [position.left]
        if let left = self[position.left] {
            guard !left.isWall else { return false }
            if left.isEmpty {
                left.value = self[position]!.value
                return true
            }
            let result = affectedPositions.map { position -> Bool in
                return pushLeft(position: position)
            }
            if (result.allSatisfy { $0 == true }) {
                print("Move \(position) to \(position.left)")
                left.value = self[position]!.value
                return true
            }
            return false
        }
        return false
    }

    private func pushRight(position: Position) -> Bool {
        let affectedPositions = [position.right]
        if let right = self[position.right] {
            guard !right.isWall else { return false }
            if right.isEmpty {
                right.value = self[position]!.value
                return true
            }
            let result = affectedPositions.map { position -> Bool in
                return pushRight(position: position)
            }
            if (result.allSatisfy { $0 == true }) {
                right.value = self[position]!.value
                return true
            }
            return false
        }
        return false
    }
}
