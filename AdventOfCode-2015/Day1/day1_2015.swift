//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

func day1_2015_A() throws -> Int {
    let lines = try FileReader(filename: "day1_2015_input").getLines()
    let line = lines.first!
    let array = Array(line).map { String($0) }
    let result = try array.reduce(into: 0) { partialResult, char in
        if char == "(" {
            partialResult += 1
        } else if char == ")" {
            partialResult -= 1
        } else {
            throw AoCError.wrongFormat
        }
    }
    return result
}

func day1_2015_B() throws -> Int {
    let lines = try FileReader(filename: "day1_2015_input").getLines()
    let line = lines.first!
    let array = Array(line).map { String($0) }
    var count = 0
    var foundIndex: Int?
    try array.enumerated().forEach { (index, char) in
        guard foundIndex == nil else { return }
        if char == "(" {
            count += 1
        } else if char == ")" {
            count -= 1
        } else {
            throw AoCError.wrongFormat
        }
        if count == -1 {
            foundIndex = index
        }
    }
    return foundIndex! + 1
}
