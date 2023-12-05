//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

private class Cell {
    let value: String
    var isValid: Bool

    init(value: String, isValid: Bool) {
        self.value = value
        self.isValid = isValid
    }

    var isDigit: Bool {
        return Int(value) != nil
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

    var digitRows: [[Int]] {
        return rows.map { row in
            let mapped = row.map { cell in
                cell.isDigit && cell.isValid ? cell.value : ";"
            }
            let joined = mapped.reduce(into: "") { partialResult, next in
                partialResult += next
            }
            let validNumbers = joined.components(separatedBy: ";").filter { $0.count > 0 }.compactMap { Int($0) }
            print(validNumbers)
            return validNumbers
        }
    }
}

private func process(_ map: Map) {
    (0...(map.maxY)).forEach { y in
        (0...(map.maxX)).forEach { x in
            if let cell = map[x, y], cell.isValid, !cell.isDigit {
                propagateValidation(map: map, currentX: x, currentY: y)
            }
        }
    }
}

private func propagateValidation(map: Map, currentX: Int, currentY: Int) {
    guard currentX >= 0, currentY >= 0 else { return }
    testAndPropagate(map: map, currentX: currentX-1, currentY: currentY-1)
    testAndPropagate(map: map, currentX: currentX-1, currentY: currentY)
    testAndPropagate(map: map, currentX: currentX-1, currentY: currentY+1)
    testAndPropagate(map: map, currentX: currentX, currentY: currentY-1)
    testAndPropagate(map: map, currentX: currentX, currentY: currentY+1)
    testAndPropagate(map: map, currentX: currentX+1, currentY: currentY-1)
    testAndPropagate(map: map, currentX: currentX+1, currentY: currentY)
    testAndPropagate(map: map, currentX: currentX+1, currentY: currentY+1)
}

private func testAndPropagate(map: Map, currentX: Int, currentY: Int) {
    guard let cell = map[currentX, currentY], cell.isDigit, !cell.isValid else {
        return
    }
    cell.isValid = true
    propagateValidation(map: map, currentX: currentX, currentY: currentY)
}

private extension String {
    var isValid: Bool {
        return !(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."].contains(self))
    }
}

private func parseLines(_ lines: [String]) throws -> Map {
    let rows = lines.map { line in
        line.map { cell in
            let string = String(cell)
            return Cell(value: string, isValid: string.isValid)
        }
    }
    return Map(rows: rows)
}

func day3_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day3_2023_input").getLines()
    let map = try parseLines(lines)
    process(map)
    let flat = map.digitRows.flatMap { $0 }
    return flat.reduce(0, +)
}

private func parseLineSecondPart(_ line: String) throws -> Int {
    return -1
}

func day3_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day3_2023_example").getLines()
    let numbers = try lines.map(parseLineSecondPart(_:))
    return numbers.reduce(0, +)
}
