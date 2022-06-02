//
//  day3.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/06/2022.
//

import Foundation

func day3_A() throws -> Int {
    let lines = try FileReader(filename: "day3_input").getLines()
    let splitted = lines.map { line -> [Int] in
        line.enumerated().compactMap { Int(String($0.element)) }
    }
    let lineCount = lines.count
    let lineCharCount = splitted.first?.count ?? 0
    let initialValue = Array(repeating: 0, count: lineCharCount)
    let sum = splitted.reduce(into: initialValue) { partialResult, element in
        let newResult = zip(partialResult, element).map(+)
        partialResult = newResult
    }
    let threshold = lineCount / 2 + (lineCount % 2)
    let gammaString = sum.map { digit in
        digit >= threshold ? "1" : "0"
    }.joined()
    let epsilonString = gammaString.map { $0 == "1" ? "0" : "1" }.joined()
    let gamma = try Int.fromBinary(string: gammaString)
    let epsilon = try Int.fromBinary(string: epsilonString)
    return gamma * epsilon
}

func day3_B() throws -> Int {
    let lines = try FileReader(filename: "day3_input").getLines()
    let stepCount = (lines.first?.count ?? 1) - 1
    var index = 0
    var linesCopy = lines
    while linesCopy.count > 1, index <= stepCount {
        linesCopy = try filter(input: linesCopy, index: index, useMostRepresentated: true)
        index += 1
    }
    let oxygen = try Int.fromBinary(string: linesCopy.first!)

    linesCopy = lines
    index = 0
    while linesCopy.count > 1, index <= stepCount {
        linesCopy = try filter(input: linesCopy, index: index, useMostRepresentated: false)
        index += 1
    }
    let co2 = try Int.fromBinary(string: linesCopy.first!)
    return oxygen * co2
}

private func filter(input: [String], index: Int, useMostRepresentated: Bool) throws -> [String] {
    let inputCount = input.count
    let digits = input.compactMap { line -> Int? in
        let digitString = String((Array(line))[index])
        let digit = Int(digitString)
        return digit
    }
    guard digits.count == inputCount else { throw AoCError.wrongFormat }
    let sum = digits.reduce(0, +)
    let threshold = inputCount / 2 + (inputCount % 2)
    let filteringDigit = sum >= threshold
    ? (useMostRepresentated ? "1" : "0")
    : (useMostRepresentated ? "0" : "1")
    return input.filter { line in
        String((Array(line))[index]) == filteringDigit
    }
}
