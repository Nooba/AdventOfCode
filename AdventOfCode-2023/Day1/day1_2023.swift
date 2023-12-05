//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

private func parseLine(_ line: String) throws -> Int {
    let onlyDigits = line.replacing(/\D+/, with: "")
    guard onlyDigits.count >= 1 else {
        throw AoCError.wrongFormat
    }
    guard let firstDigit = onlyDigits.first,
          let first = Int(String(firstDigit)),
          let secondDigit = onlyDigits.last,
          let last = Int(String(secondDigit)) else  {
        throw AoCError.wrongFormat
    }
    return first * 10 + last
}

func day1_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day1_2023_input").getLines()
    let numbers = try lines.map(parseLine(_:))
    return numbers.reduce(0, +)
}

private let spelledOut = [
    ("one", 1),
    ("1", 1),
    ("two", 2),
    ("2", 2),
    ("three", 3),
    ("3", 3),
    ("four", 4),
    ("4", 4),
    ("five", 5),
    ("5", 5),
    ("six", 6),
    ("6", 6),
    ("seven", 7),
    ("7", 7),
    ("eight", 8),
    ("8", 8),
    ("nine", 9),
    ("9", 9)
]

private func parseLineSecondPart(_ line: String) throws -> Int {
    var currentBucket: [Int: Int] = [:]
    for tuple in spelledOut {
        let capturePattern = tuple.0
        let captureRegex = try! NSRegularExpression(pattern: capturePattern, options: [])
        let lineRange = NSRange(line.startIndex..<line.endIndex, in: line)
        let matches = captureRegex.matches(in: line, options: [], range: lineRange)
        matches.forEach { match in
            currentBucket[match.range.location] = tuple.1
        }
    }
    let mappedLine = currentBucket.keys.sorted().reduce(into: "") { partialResult, key in
        if let value = currentBucket[key] {
            partialResult += "\(value)"
        }
    }
    let onlyDigits = mappedLine.replacing(/\D+/, with: "")
    guard onlyDigits.count >= 1 else {
        throw AoCError.wrongFormat
    }
    guard let firstDigit = onlyDigits.first,
          let first = Int(String(firstDigit)),
          let secondDigit = onlyDigits.last,
          let last = Int(String(secondDigit)) else  {
        throw AoCError.wrongFormat
    }
    return first * 10 + last
}


func day1_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day1_2023_input").getLines()
    let numbers = try lines.map(parseLineSecondPart(_:))
    return numbers.reduce(0, +)
}
