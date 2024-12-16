//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation

private struct Position: CustomStringConvertible {
    let x: Int
    let y: Int

    var description: String {
        return "\(x), \(y)"
    }
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
    let emptySpace = warehouse.findEmptySpace(from: robot, inDirection: direction)
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

func day15_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day15_2024_input").getLines()
    return -1
}
