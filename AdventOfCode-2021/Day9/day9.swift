//
//  day9.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 10/06/2022.
//

import Foundation

fileprivate struct HeightMap {
    struct Row {
        var cells: [Cell]
    }

    struct Cell {
        let value: Int
    }

    var rows: [Row]

    init(input: [String]) throws {
        rows = try input.map { rowString in
            let ints = try rowString.enumerated().map { element -> Int in
                guard let int = Int(String(element.element as Character)) else {
                    throw AoCError.wrongFormat
                }
                return int
            }
            let cells = ints.map { Cell(value: $0) }
            return Row(cells: cells)
        }
    }

    var fourLinkedLowPoints: [Int] {
        rows.enumerated().flatMap { element -> [Int] in
            let (rowIndex, row) = element
            return row.cells.enumerated().compactMap { element -> Int? in
                let (cellIndex, cell) = element
                let previousCellValue = row.cells[safe: cellIndex - 1]?.value ?? 9
                let nextCellValue = row.cells[safe: cellIndex + 1]?.value ?? 9
                if cell.value == 9 { return nil }
                if cell.value >= previousCellValue || cell.value >= nextCellValue { return nil }
                let topCellValue = rows[safe: rowIndex - 1]?.cells[cellIndex].value ?? 9
                let bottomCellValue = rows[safe: rowIndex + 1]?.cells[cellIndex].value ?? 9
                if cell.value >= topCellValue || cell.value >= bottomCellValue { return nil }
                return cell.value
            }
        }
    }
}


func day9_A() throws -> Int {
    let lines = try FileReader(filename: "day9_input").getLines()
    let heightMap = try HeightMap(input: lines)
    let lowPoints = heightMap.fourLinkedLowPoints
    return lowPoints.reduce(lowPoints.count, +)
}

//func day9_A_bis() throws -> Int {
//    let lines = try FileReader(filename: "day9_input").getLines()
//
//    let heightMap = try HeightMap(input: lines)
//    let lowPoints = heightMap.fourLinkedLowPoints
//    return lowPoints.reduce(lowPoints.count, +)
//}
