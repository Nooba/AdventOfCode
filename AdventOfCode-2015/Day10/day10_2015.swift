//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

// This is not efficient enough, takes too long to execute
private func enunciate(_ string: String) -> String {
    var current: Character?
    var index = 0
    var result = ""
    var count = 1
    while index < string.count {
        defer { index += 1 }
        guard let nonOptionalCurrent = current else {
            current = string[string.index(string.startIndex, offsetBy: index)]
            count = 1
            continue
        }
        let next = string[string.index(string.startIndex, offsetBy: index)]
        if current == next {
            count += 1
        } else {
            result.append("\(count)\(nonOptionalCurrent)")
            current = next
            count = 1
        }
    }
    if let current {
        result.append("\(count)\(current)")
    }
    return result
}

private func numberOfDigits(_ number: Int) -> Int {
    if number > 0 {
        return numberOfDigits(number / 10) + 1
    }
    return 0
}

private func digit(from number: Int, at index: Int) -> Int {
    let size = numberOfDigits(number)
    let power = size - (index + 1)
    return (number / Int(truncating: pow(10, power) as NSNumber)) % 10
}

// Add this gives an arithmetic error
private func enunciate(_ number: Int) -> Int {
    var current: Int?
    let size = numberOfDigits(number)
    var index = 0
    var result = 0
    var count = 1
    while index < size {
        defer { index += 1 }
        guard let nonOptionalCurrent = current else {
            current = digit(from: number, at: index)
            count = 1
            continue
        }
        let next = digit(from: number, at: index)
        if current == next {
            count += 1
        } else {
            result *= 100
            result += 10 * count + nonOptionalCurrent
            current = next
            count = 1
        }
    }
    if let current {
        result *= 100
        result += 10 * count + current
    }
    return result
}

// This is better, altough still long for 50 iterations (~1min)
private func enunciateViaRegexp(_ input: String) -> String {
    return input.replacing(/(\d)\1*/) { match -> String in
        let size = input.distance(from: match.range.lowerBound, to: match.range.upperBound)
        let string = String(input[match.range])
        let number = String(string[string.startIndex])
        let replacement = "\(size)\(number)"
        return replacement
    }
}


func day10_2015_A() throws -> Int {
    let lines = try FileReader(filename: "day10_2015_input").getLines()
    var input = lines[0]
    (0..<40).forEach { i in
        input = enunciateViaRegexp(input)
    }
    return input.count
}

// MARK: - Part 2

func day10_2015_B() throws -> Int {
    let lines = try FileReader(filename: "day10_2015_input").getLines()
    var input = lines[0]
    (0..<50).forEach { i in
        input = enunciateViaRegexp(input)
    }
    return input.count
}
