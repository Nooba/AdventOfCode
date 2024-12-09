//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation
import Algorithms

private class Cell {
    let value: String
    var antinodeOf: [String]

    init(value: String, antinodeOf: [String]) {
        self.value = value
        self.antinodeOf = antinodeOf
    }
}

private struct Position: Hashable {
    let x: Int
    let y: Int
}

private struct Map {
    let rows: [[Cell]]
    let antennas: [String: [Position]]

    init(rows: [[Cell]], antennas: [String : [Position]]) {
        self.rows = rows
        self.antennas = antennas
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

    func processAntinodes(at position: Position?) {
        guard let position, let cell = self[position] else { return }
        antennas.forEach { (key, antennaPositions) in
            guard cell.antinodeOf.isEmpty else { return }
            let foundMatchingAntenna = antennaPositions.first { antennaPosition in
                guard antennaPosition != position else { return false }
                let vector = ((antennaPosition.x - position.x), (antennaPosition.y - position.y))
                let positionToCheck = Position(x: antennaPosition.x + vector.0, y: antennaPosition.y + vector.1)
                guard let cellToCheck = self[positionToCheck] else { return false }
                return cellToCheck.value == key
            }
            if foundMatchingAntenna != nil {
//                print(foundMatchingAntenna)
                cell.antinodeOf.append(key)
            }
        }
    }

    var totalAntinodes: Int {
        return rows.compactMap { row in
            row.filter { !$0.antinodeOf.isEmpty }.count
        }.reduce(0, +)
    }
}

private func parseLines(_ lines: [String]) -> Map {
    var antennas = [String: [Position]]()
    let rows = lines.enumerated().map { (indexRow, line) in
        line.enumerated().map { (indexLine, cell) in
            let string = String(cell)
            if string != "." {
                var array = antennas[string] ?? []
                array.append(Position(x: indexLine, y: indexRow))
                antennas[string] = array
            }
            return Cell(value: string, antinodeOf: [])
        }
    }
    return Map(rows: rows, antennas: antennas)
}

private func process(_ map: Map) {
    (0...(map.maxY)).forEach { y in
        (0...(map.maxX)).forEach { x in
            map.processAntinodes(at: Position(x: x, y: y))
        }
    }
}

func day8_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day8_2024_input").getLines()
    let map = parseLines(lines)
    process(map)
    return map.totalAntinodes
}

// MARK: - Part B

private extension Map {
    func processAntinodesSecondPart() {
        antennas.forEach { (key, antennaPositions) in
            for pair in antennaPositions.combinations(ofCount: 2) {
                let (left, right) = (pair[0], pair[1])
                let vector = ((left.x - right.x), (left.y - right.y))
                var mult = 1
                var positionToCheck = Position(x: left.x + mult * vector.0, y: left.y + mult * vector.1)
                var cellToCheck = self[positionToCheck]
                while cellToCheck != nil {
                    cellToCheck!.antinodeOf.append(key)
                    mult += 1
                    positionToCheck = Position(x: left.x + mult * vector.0, y: left.y + mult * vector.1)
                    cellToCheck = self[positionToCheck]
                }

                mult = -1
                positionToCheck = Position(x: right.x + mult * vector.0, y: right.y + mult * vector.1)
                cellToCheck = self[positionToCheck]
                while cellToCheck != nil {
                    if cellToCheck!.antinodeOf.isEmpty {
                        cellToCheck!.antinodeOf.append(key)
                    }
                    mult -= 1
                    positionToCheck = Position(x: right.x + mult * vector.0, y: right.y + mult * vector.1)
                    cellToCheck = self[positionToCheck]
                }
            }
        }
    }

    var totalAntinodesSecondPart: Int {
        return rows.compactMap { row in
            row.filter { !$0.antinodeOf.isEmpty || $0.value != "." }.count
        }.reduce(0, +)
    }
}

func day8_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day8_2024_input").getLines()
    let map = parseLines(lines)
    map.processAntinodesSecondPart()
    return map.totalAntinodesSecondPart
}
