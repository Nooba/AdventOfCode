//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

private struct Ticket {
    let winningNumbers: [Int]
    let drawnNumbers: [Int]

    var winningCount: Int {
        let count = drawnNumbers.reduce(into: 0) { partialResult, drawn in
            partialResult += winningNumbers.contains(drawn) ? 1 : 0
        }
        return count
    }

    var value: Int {
        let power = drawnNumbers.reduce(into: 0) { partialResult, drawn in
            partialResult += winningNumbers.contains(drawn) ? 1 : 0
        }
        return 1 << (power - 1)
    }
}

private func numbers(from string: String) -> [Int] {
    let compos = string.components(separatedBy: CharacterSet.whitespaces)
    return compos.compactMap { Int($0) }
}

private func parseLine(_ line: String) throws -> Ticket {
    let ticket = try parseRegexp(line, capturePattern: #"Card( )+(\d+): (.*)"#) { groups in
        let compos = groups[2].components(separatedBy: " | ")
        let winning = numbers(from: compos[0])
        let drawn = numbers(from: compos[1])
        return Ticket(winningNumbers: winning, drawnNumbers: drawn)
    }
    return ticket
}

func day4_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day4_2023_input").getLines()
    let tickets = try lines.map(parseLine(_:))
    return tickets.map { $0.value }.reduce(0, +)
}

func day4_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day4_2023_input").getLines()
    let tickets = try lines.map(parseLine(_:))
    var buckets = Array(repeating: 1, count: tickets.count)
    tickets.enumerated().forEach { (index, ticket) in
        guard ticket.winningCount > 0 else {
            return
        }
        (1...ticket.winningCount).forEach { offset in
            buckets[index + offset] += buckets[index]
        }
    }
    return buckets.reduce(0, +)
}
