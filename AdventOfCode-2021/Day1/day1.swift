//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

fileprivate func countIncreases(_ ints: [Int]) -> Int {
    var currentValue: Int?
    var count = 0
    ints.forEach { value in
        guard let current = currentValue else {
            currentValue = value
            return
        }
        if current < value {
            count += 1
        }
        currentValue = value
    }
    return count
}

func day1_A() throws -> Int {
    let lines = try FileReader(filename: "day1_input").getLines()
    let ints = try lines.map { line -> Int in
        guard let value = Int(line) else {
            throw AoCError.wrongFormat
        }
        return value
    }
    return countIncreases(ints)
}

func day1_B() throws -> Int {
    let lines = try FileReader(filename: "day1_input").getLines()
    let ints = try lines.map { line -> Int in
        guard let value = Int(line) else {
            throw AoCError.wrongFormat
        }
        return value
    }
    let aggregatedInts = ints.enumerated().compactMap { element -> Int? in
        let (index, value) = element
        guard index < ints.count - 2 else {
            return nil
        }
        return value + ints[index+1] + ints[index+2]
    }
    return countIncreases(aggregatedInts)
}
