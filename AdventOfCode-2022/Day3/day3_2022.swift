//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

private func getCommonItem(_ string: String) throws -> String {
    let firstHalf = String(string.prefix(string.count / 2))
    let firstSet = Set((Array(firstHalf).map { String($0) }))
    let secondHalf = string.suffix(string.count / 2)
    let secondSet = Set((Array(secondHalf).map { String($0) }))
    let intersection = firstSet.intersection(secondSet)
    guard (intersection.count == 1) else {
        throw AoCError.wrongFormat
    }
    let result = intersection.first!

    return result
}

private func getCommonItem(_ strings: [String]) throws -> String {
    let sets = strings.map { Set((Array($0).map { String($0) })) }
    let intersection = sets.reduce(sets.first!) { partialResult, nextSet in
        partialResult.intersection(nextSet)
    }
    guard (intersection.count == 1) else {
        throw AoCError.wrongFormat
    }
    let result = intersection.first!
    return result
}

private func getPriority(_ string: String) -> Int {
    let priorities = [
        "a": 1,
        "b": 2,
        "c": 3,
        "d": 4,
        "e": 5,
        "f": 6,
        "g": 7,
        "h": 8,
        "i": 9,
        "j": 10,
        "k": 11,
        "l": 12,
        "m": 13,
        "n": 14,
        "o": 15,
        "p": 16,
        "q": 17,
        "r": 18,
        "s": 19,
        "t": 20,
        "u": 21,
        "v": 22,
        "w": 23,
        "x": 24,
        "y": 25,
        "z": 26,
        "A": 27,
        "B": 28,
        "C": 29,
        "D": 30,
        "E": 31,
        "F": 32,
        "G": 33,
        "H": 34,
        "I": 35,
        "J": 36,
        "K": 37,
        "L": 38,
        "M": 39,
        "N": 40,
        "O": 41,
        "P": 42,
        "Q": 43,
        "R": 44,
        "S": 45,
        "T": 46,
        "U": 47,
        "V": 48,
        "W": 49,
        "X": 50,
        "Y": 51,
        "Z": 52
    ]
    return priorities[string]!
}

func day3_2022_A() throws -> Int {
    let lines = try FileReader(filename: "day3_2022_input").getLines()
    let items = try lines.map { try getCommonItem($0) }
    let priorities = items.map { getPriority($0) }
    return priorities.reduce(0, +)
}

func day3_2022_B() throws -> Int {
    let groupedLines = try FileReader(filename: "day3_2022_input").getGroupedLinesByCount(3)
    let items = try groupedLines.map { try getCommonItem($0) }
    let priorities = items.map { getPriority($0) }
    return priorities.reduce(0, +)
}
