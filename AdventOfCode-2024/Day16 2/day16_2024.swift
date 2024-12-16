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

    var above: Position { Position(x: x, y: y-1) }
    var below: Position { Position(x: x, y: y+1) }
    var left: Position { Position(x: x-1, y: y) }
    var right: Position { Position(x: x+1, y: y) }
}

private enum Direction: String, CaseIterable {
    case up = "^"
    case left = "<"
    case right = ">"
    case down = "v"

    var opposite: Direction {
        switch self {
        case .up:
            return .down
        case .left:
            return .right
        case .right:
            return .left
        case .down:
            return .up
        }
    }
}

private enum Object: String {
    case wall = "#"
    case empty = "."
    case start = "S"
    case exit = "E"
}

private class Cell: CustomStringConvertible {
    var value: Object
    var cost: Int
    var orientation: Direction?

    init(value: Object, cost: Int) {
        self.value = value
        self.cost = cost
        switch value {
        case .start:
            orientation = .right
        default:
            orientation = nil
        }
    }

    var isEmpty: Bool {
        value == .empty
    }

    var isWall: Bool {
        value == .wall
    }

    var isStart: Bool {
        value == .start
    }

    var isEnd: Bool {
        value == .exit
    }

    var description: String {
        if let orientation {
            return orientation.rawValue
        }
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

    func findCell(value: Object) -> Position {
        let position = rows.enumerated().compactMap { iterator in
            let (y, row) = iterator
            return row.enumerated().compactMap { rowIterator in
                let (x, cell) = rowIterator
                switch value {
                case .wall:
                    assertionFailure()
                case .empty:
                    assertionFailure()
                case .start:
                    if cell.isStart { return Position(x: x, y: y) }
                case .exit:
                    if cell.isEnd { return Position(x: x, y: y) }
                }
                return nil
            }.first
        }.first
        return position!
    }

//    func findEmptySpace(from position: Position, inDirection direction: Direction) -> Position? {
//        switch direction {
//        case .up:
//            var y = position.y - 1
//            var foundWall = false
//            while y > 0, !foundWall {
//                let newPosition = Position(x: position.x, y: y)
//                let cell = self[newPosition]!
//                if cell.isEmpty { return newPosition }
//                if cell.isWall { foundWall = true }
//                y -= 1
//            }
//            return nil
//        case .left:
//            var x = position.x - 1
//            var foundWall = false
//            while x > 0, !foundWall {
//                let newPosition = Position(x: x, y: position.y)
//                let cell = self[newPosition]!
//                if cell.isEmpty { return newPosition }
//                if cell.isWall { foundWall = true }
//                x -= 1
//            }
//            return nil
//        case .right:
//            var x = position.x + 1
//            var foundWall = false
//            while x > 0, !foundWall {
//                let newPosition = Position(x: x, y: position.y)
//                let cell = self[newPosition]!
//                if cell.isEmpty { return newPosition }
//                if cell.isWall { foundWall = true }
//                x += 1
//            }
//            return nil
//        case .down:
//            var y = position.y + 1
//            var foundWall = false
//            while y > 0, !foundWall {
//                let newPosition = Position(x: position.x, y: y)
//                let cell = self[newPosition]!
//                if cell.isEmpty { return newPosition }
//                if cell.isWall { foundWall = true }
//                y += 1
//            }
//            return nil
//        }
//    }
}

private func parseMap(_ lines: [String]) throws -> Map {
    let rows = lines.map { line in
        line.map { cell in
            let string = String(cell)
            return Cell(value: Object(rawValue: string)!, cost: 0)
        }
    }
    return Map(rows: rows)
}

private extension Map {

    var shouldStop: Bool {
        let exit = findCell(value: .exit)
        return !shouldCompute(at: exit)
    }

    func shouldCompute(at position: Position) -> Bool {
        guard let cell = self[position], (cell.value == .empty || cell.value == .exit) else { return false }
        let (x, y) = (position.x, position.y)
        if let topCell = self[Position(x: x, y: y-1)], topCell.isEmpty, topCell.orientation == nil {
            return true
        }
        if let leftCell = self[Position(x: x-1, y: y)], leftCell.isEmpty, leftCell.orientation == nil {
            return true
        }
        if let rightCell = self[Position(x: x+1, y: y)], rightCell.isEmpty, rightCell.orientation == nil {
            return true
        }
        if let bottomCell = self[Position(x: x, y: y+1)], bottomCell.isEmpty, bottomCell.orientation == nil {
            return true
        }
        return false
    }

    func computeCosts() -> Int {
        while !shouldStop {
            (0..<(maxY)).forEach { y in
                (0..<(maxX)).forEach { x in
                    if let cell = self[x, y], shouldCompute(at: Position(x: x, y: y)) {
                        let fromTopCost = computeCost(from: Position(x: x, y: y-1), to: Position(x: x, y: y))
                        let fromBottomCost = computeCost(from: Position(x: x, y: y+1), to: Position(x: x, y: y))
                        let fromLeftCost = computeCost(from: Position(x: x-1, y: y), to: Position(x: x, y: y))
                        let fromRightCost = computeCost(from: Position(x: x+1, y: y), to: Position(x: x, y: y))
                        if let foundCost = [fromTopCost, fromBottomCost, fromLeftCost, fromRightCost].sorted(by: { leftPair, rightPair in
                            leftPair.0 < rightPair.0
                        }).first(where: { $0.0 > 0 }) {
                            if foundCost.0 < cell.cost {
                                cell.cost = foundCost.0
                                cell.orientation = foundCost.1
                            }
                        }
                    }
                }
            }
            print("\n")
//            print(self)
        }
        return self[findCell(value: .exit)]!.cost
    }

    func computeCost(from origin: Position, to destination: Position) -> (Int, Direction) {
        guard let originCell = self[origin], originCell.value != .wall, (originCell.cost != 0 || originCell.value == .start) else { return (0, .right) }
        if origin.x == destination.x, destination.y == origin.y + 1 { // lower destination
            switch originCell.orientation {
            case .up:
                return (0, .down)
            case .down:
                return (originCell.cost + 1, .down)
            case .left:
                return (originCell.cost + 1001, .down)
            case .right:
                return (originCell.cost + 1001, .down)
            case .none:
                return (0, .down)
            }
        }
        if origin.x == destination.x, destination.y == origin.y - 1 { // upper destination
            switch originCell.orientation {
            case .up:
                return (originCell.cost + 1, .up)
            case .down:
                return (0, .up)
            case .left:
                return (originCell.cost + 1001, .up)
            case .right:
                return (originCell.cost + 1001, .up)
            case .none:
                return (0, .up)
            }
        }
        if origin.y == destination.y, destination.x == origin.x + 1 { // right destination
            switch originCell.orientation {
            case .up:
                return (originCell.cost + 1001, .right)
            case .down:
                return (originCell.cost + 1001, .right)
            case .left:
                return (0, .right)
            case .right:
                return (originCell.cost + 1, .right)
            case .none:
                return (0, .right)
            }
        }
        if origin.y == destination.y, destination.x == origin.x - 1 { // left destination
            switch originCell.orientation {
            case .up:
                return (originCell.cost + 1001, .left)
            case .down:
                return (originCell.cost + 1001, .left)
            case .left:
                return (originCell.cost + 1, .left)
            case .right:
                return (0, .left)
            case .none:
                return (0, .left)
            }
        }
        return (0, .right)
    }
}

private extension Map {
    func computeProperCosts() -> Int {
        var cellsToPropagateFrom = [findCell(value: .start)]
        while !cellsToPropagateFrom.isEmpty {
            var nextCells = cellsToPropagateFrom.flatMap { cell in
                propagate(from: cell)
            }
            cellsToPropagateFrom = nextCells
            print(self)
        }
        return self[findCell(value: .exit)]!.cost
    }

    // MARK: - Private

    private func propagate(from origin: Position) -> [Position] {
        guard let cell = self[origin], let originOrientation = cell.orientation else { return [] }
        var nextCells = [Position]()
        Direction.allCases.forEach { direction in
            guard direction != originOrientation.opposite else { return }
            switch direction {
            case .left:
                if let leftCell = self[origin.left], !leftCell.isWall {
                    let newCost = computeCost(from: origin, to: origin.left)
                    if newCost.0 < leftCell.cost || leftCell.cost == 0 {
                        leftCell.cost = newCost.0
                        leftCell.orientation = direction
                        nextCells.append(origin.left)
                    }
                }
            case .right:
                if let rightCell = self[origin.right], !rightCell.isWall {
                    let newCost = computeCost(from: origin, to: origin.right)
                    if newCost.0 < rightCell.cost || rightCell.cost == 0 {
                        rightCell.cost = newCost.0
                        rightCell.orientation = direction
                        nextCells.append(origin.right)
                    }
                }
            case .up:
                if let upCell = self[origin.above], !upCell.isWall {
                    let newCost = computeCost(from: origin, to: origin.above)
                    if newCost.0 < upCell.cost || upCell.cost == 0 {
                        upCell.cost = newCost.0
                        upCell.orientation = direction
                        nextCells.append(origin.above)
                    }
                }

            case .down:
                if let downCell = self[origin.below], !downCell.isWall {
                    let newCost = computeCost(from: origin, to: origin.below)
                    if newCost.0 < downCell.cost || downCell.cost == 0 {
                        downCell.cost = newCost.0
                        downCell.orientation = direction
                        nextCells.append(origin.below)
                    }
                }
            }
        }
        return nextCells
    }
}

func day16_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day16_2024_input").getLines()
    let map = try parseMap(lines)
    print(map)
    let result = map.computeProperCosts()
    print(map)
    return result
}

// MARK: - Part B

func day16_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day16_2024_input").getLines()
    return -1
}
