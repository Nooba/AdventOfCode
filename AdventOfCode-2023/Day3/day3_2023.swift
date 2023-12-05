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

    init(value: String, isValid: Bool, adjacentNumbers: [Int]) {
        self.value = value
        self.isValid = isValid
        self.adjacentNumbers = adjacentNumbers
    }

    var isDigit: Bool {
        return Int(value) != nil
    }

    var isPotentialGear: Bool {
        return value == "*"
    }
    var adjacentNumbers: [Int]
    var isGear: Bool { isPotentialGear && adjacentNumbers.count == 2 }
    var gearPower: Int {
        guard !adjacentNumbers.isEmpty else { return 0 }
        return adjacentNumbers.reduce(1, *)
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

    func numberAt(x: Int, y: Int) -> Int? {
        var currentMinX = x
        var currentMaxX = x
        while let previous = self[currentMinX - 1, y], previous.isDigit {
            currentMinX -= 1
        }
        while let next = self[currentMaxX + 1, y], next.isDigit {
            currentMaxX += 1
        }
        let intString = (currentMinX...currentMaxX).map { x in
            self[x, y]!.value
        }.joined()
        return Int(intString)
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
            return Cell(value: string, isValid: string.isValid, adjacentNumbers: [])
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


private func processSecondPart(_ map: Map) {
    (0...(map.maxY)).forEach { y in
        (0...(map.maxX)).forEach { x in
            if let cell = map[x, y], cell.isPotentialGear {
                updatePotentialGearCell(map, x: x, y: y)
            }
        }
    }
}

private func updatePotentialGearCell(_ map: Map, x: Int, y: Int) {
    var adjacentDigits = [
        map[x-1, y],
        map[x+1, y],
    ]
    if let top = map[x, y-1], top.isDigit {
        adjacentDigits.append(top)
    } else {
        adjacentDigits.append(map[x-1, y-1])
        adjacentDigits.append(map[x+1, y-1])
    }
    if let top = map[x, y+1], top.isDigit {
        adjacentDigits.append(top)
    } else {
        adjacentDigits.append(map[x-1, y+1])
        adjacentDigits.append(map[x+1, y+1])
    }
    guard adjacentDigits.compactMap({ $0 }).filter({ $0.isDigit }).count == 2 else {
        return
    }

    var adjacentNumbers = [
        map.numberAt(x: x-1, y: y),
        map.numberAt(x: x+1, y: y)
    ]
    if let top = map[x, y-1], top.isDigit {
        adjacentNumbers.append(map.numberAt(x: x, y: y-1))
    } else {
        adjacentNumbers.append(map.numberAt(x: x-1, y: y-1))
        adjacentNumbers.append(map.numberAt(x: x+1, y: y-1))
    }
    if let top = map[x, y+1], top.isDigit {
        adjacentNumbers.append(map.numberAt(x: x, y: y+1))
    } else {
        adjacentNumbers.append(map.numberAt(x: x-1, y: y+1))
        adjacentNumbers.append(map.numberAt(x: x+1, y: y+1))
    }

    let adjacent = adjacentNumbers.compactMap { $0 }
    map[x, y]?.adjacentNumbers = adjacent
}

func day3_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day3_2023_input").getLines()
    let map = try parseLines(lines)
    processSecondPart(map)
    let flat = map.rows.flatMap { $0.map { $0.gearPower } }
    return flat.reduce(0, +)
}
