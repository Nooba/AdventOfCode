//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

private func initiateBoard(_ lines: [String]) -> [Int:[String]] {
    var content: [Int:[String]] = [:]
    lines.forEach { line in
        line.enumerated().forEach { (index, char) in
            let character = String(char)
            if let _ = Int(character) {
                return
            }
            guard character != " ", character != "[", character != "]" else {
                return
            }
            guard index % 4 == 1 else {
                return
            }
            var new = content[(index/4)+1] ?? []
            new.insert(character, at: 0)
            content[(index/4)+1] = new
        }
    }
    return content
}

private func parseAction(_ line: String) throws -> (Int, Int, Int) {
    let capturePattern = #"move (\d+) from (\d+) to (\d+)"#
    let captureRegex = try! NSRegularExpression(
        pattern: capturePattern,
        options: []
    )
    let lineRange = NSRange(
        line.startIndex..<line.endIndex,
        in: line
    )

    let matches = captureRegex.matches(
        in: line,
        options: [],
        range: lineRange
    )
    guard let match = matches.first else {
        // Handle exception
        throw AoCError.wrongFormat
    }
    var actions: [String] = []
    for rangeIndex in 0..<match.numberOfRanges {
        let matchRange = match.range(at: rangeIndex)

        // Ignore matching the entire username string
        if matchRange == lineRange { continue }

        // Extract the substring matching the capture group
        if let substringRange = Range(matchRange, in: line) {
            let capture = String(line[substringRange])
            actions.append(capture)
        }
    }
    let intActions = actions.map { Int($0)! }
    return (intActions[0], intActions[1], intActions[2])
}

func day5_2022_A() throws -> String {
    let lines = try FileReader(filename: "day5_2022_input").getGroupedLines(false)
    var board = initiateBoard(lines.first!)
    let actions = try lines.last!.map(parseAction(_:))
    actions.forEach { (moves, orig, dest) in
        var originArray = board[orig] ?? []
        var destArray = board[dest] ?? []
        for _ in 1...moves {
            if let pop = originArray.popLast() {
                destArray.append(pop)
            }
        }
        board[orig] = originArray
        board[dest] = destArray
    }
    var result = ""
    for i in 1...board.count {
        result += (board[i]?.last ?? "")
    }
    return result
}

func day5_2022_B() throws -> String {
    let lines = try FileReader(filename: "day5_2022_input").getGroupedLines(false)
    var board = initiateBoard(lines.first!)
    let actions = try lines.last!.map(parseAction(_:))
    actions.forEach { (moves, orig, dest) in
        var originArray = board[orig] ?? []
        var destArray = board[dest] ?? []
        let slice = originArray.suffix(moves)
        originArray = originArray.dropLast(moves)
        destArray.append(contentsOf: slice)
        board[orig] = originArray
        board[dest] = destArray
    }
    var result = ""
    for i in 1...board.count {
        result += (board[i]?.last ?? "")
    }
    return result

}
