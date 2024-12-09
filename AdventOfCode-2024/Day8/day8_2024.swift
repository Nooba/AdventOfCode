//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation

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

func day8_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day8_2024_input").getLines()
    let map = parseLines(lines)
    return -1
}
