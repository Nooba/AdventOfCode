//
//  day4.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/06/2022.
//

import Foundation

fileprivate struct Board {
    struct Row {
        var cells: [Cell]

        mutating func checkIfPresent(number: Int) -> Int {
            var foundIndex: Int = -1
            let newCells = cells.enumerated().map { element -> Cell in
                let (index, cell) = element
                guard cell.value == number else {
                    return cell
                }
                foundIndex = index
                return cell.checkedCopy
            }
            cells = newCells
            return foundIndex
        }

        var isWinning: Bool {
            return cells.allSatisfy { $0.checked }
        }

        var rowValue: Int {
            return cells.reduce(into: 0) { partialResult, cell in
                partialResult += cell.checked ? 0 : cell.value
            }
        }
    }

    struct Cell {
        let value: Int
        var checked: Bool

        var checkedCopy: Cell {
            return Cell(value: value, checked: true)
        }
    }

    var rows: [Row]
    var isPlayable: Bool = true

    init(input: [String]) throws {
        rows = try input.map { rowString in
            let cells = try rowString.components(separatedBy: .whitespaces).compactMap { numberString -> Cell? in
                guard !numberString.isEmpty else { return nil }
                guard let digit = Int(numberString) else { throw AoCError.wrongFormat }
                return Cell(value: digit, checked: false)
            }
            return Row(cells: cells)
        }
    }

    mutating func check(number: Int) -> (Int, Int)? {
        var foundRowIndex: Int = -1
        var foundIndex: Int = -1
        let newRows = rows.enumerated().map { element -> Row in
            var (index, row) = element
            guard foundRowIndex == -1 else {
                return row
            }
            foundIndex = row.checkIfPresent(number: number)
            if foundIndex != -1 {
                foundRowIndex = index
            }
            return row
        }
        rows = newRows
        if foundRowIndex != -1 && foundIndex != -1 {
            return (foundRowIndex, foundIndex)
        }
        return nil
    }

    func isBoardWon(lastChecked: (Int, Int)) -> Bool {
        let (rowIndex, columnIndex) = lastChecked
        if rows[rowIndex].isWinning {
            return true
        }
        if (rows.allSatisfy { $0.cells[columnIndex].checked }) {
            return true
        }
//        if rowIndex == columnIndex {
//            // check diago
//            var i = 0
//            let diagCheck = rows.allSatisfy { row in
//                let value = row.cells[i].checked
//                i += 1
//                return value
//            }
//            if diagCheck {
//                return true
//            }
//        }
//        if rowIndex == (rows.count - 1 - columnIndex) {
//            // check reverse diag
//            var i = rows.count - 1
//            let diagCheck = rows.allSatisfy { row in
//                let value = row.cells[i].checked
//                i -= 1
//                return value
//            }
//            if diagCheck {
//                return true
//            }
//        }
        return false
    }

    var boardValue: Int {
        return rows.reduce(into: 0) { partialResult, row in
            partialResult += row.rowValue
        }
    }
}

func day4_A() throws -> Int {
    let groupedLines = try FileReader(filename: "day4_input").getGroupedLines()
    let draw = try groupedLines.first?.first?.components(separatedBy: ",").compactMap({ drawString -> Int? in
        guard !drawString.isEmpty else { return nil }
        guard let digit = Int(drawString) else { throw AoCError.wrongFormat }
        return digit
    }) ?? []
    let boardStrings = groupedLines[1..<groupedLines.count]
    var boards = try boardStrings.map { try Board(input: $0) }
    var winningBoard: Board?
    var winningDraw: Int?
    draw.forEach { drawnNumber in
        guard winningBoard == nil, winningDraw == nil else {
            return
        }
        boards = boards.map { board -> Board in
            var boardCopy = board
            if let checkedIndexes = boardCopy.check(number: drawnNumber),
               boardCopy.isBoardWon(lastChecked: checkedIndexes) {
                winningBoard = boardCopy
                winningDraw = drawnNumber
            }
            return boardCopy
        }
    }
    guard
        let winningBoard = winningBoard,
        let winningDraw = winningDraw else {
        throw AoCError.resultNotFound
    }
    return winningBoard.boardValue * winningDraw
}

func day4_B() throws -> Int {
    let groupedLines = try FileReader(filename: "day4_input").getGroupedLines()
    let draw = try groupedLines.first?.first?.components(separatedBy: ",").compactMap({ drawString -> Int? in
        guard !drawString.isEmpty else { return nil }
        guard let digit = Int(drawString) else { throw AoCError.wrongFormat }
        return digit
    }) ?? []
    let boardStrings = groupedLines[1..<groupedLines.count]
    var boards = try boardStrings.map { try Board(input: $0) }
    var leftoverBoardsCount = boards.count
    var lastWinningBoard: Board?
    var lastWinningDraw: Int?
    draw.forEach { drawnNumber in
        guard lastWinningDraw == nil, lastWinningBoard == nil else {
            return
        }
        boards = boards.map { board -> Board in
            guard board.isPlayable else { return board }
            var boardCopy = board
            if let checkedIndexes = boardCopy.check(number: drawnNumber),
               boardCopy.isBoardWon(lastChecked: checkedIndexes) {
                boardCopy.isPlayable = false
                leftoverBoardsCount -= 1
                if leftoverBoardsCount == 0 {
                    lastWinningBoard = boardCopy
                    lastWinningDraw = drawnNumber
                }
            }
            return boardCopy
        }
    }
    guard
        let winningBoard = lastWinningBoard,
        let winningDraw = lastWinningDraw else {
        throw AoCError.resultNotFound
    }
    return winningBoard.boardValue * winningDraw
}
