//
//  day6.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 09/06/2022.
//

import Foundation

func day6_A() throws -> Int {
    let line = try FileReader(filename: "day6_input").getLines().first!
    let numberStrings = line.components(separatedBy: ",")
    let numbers = try numberStrings.map { string -> Int in
        guard let number = Int(string) else {
            throw AoCError.wrongFormat
        }
        return number
    }
    var buckets = Array(repeating: 0, count: 9)
    numbers.forEach { number in
        buckets[number] += 1
    }
    for _ in (1...80) {
        var copy = Array(repeating: 0, count: 9)
        copy[8] = buckets[0]
        copy[7] = buckets[8]
        copy[6] = buckets[7] + buckets[0]
        copy[5] = buckets[6]
        copy[4] = buckets[5]
        copy[3] = buckets[4]
        copy[2] = buckets[3]
        copy[1] = buckets[2]
        copy[0] = buckets[1]
        buckets = copy
    }
    return buckets.reduce(0, +)
}

func day6_B() throws -> Int {
    let line = try FileReader(filename: "day6_input").getLines().first!
    let numberStrings = line.components(separatedBy: ",")
    let numbers = try numberStrings.map { string -> Int in
        guard let number = Int(string) else {
            throw AoCError.wrongFormat
        }
        return number
    }
    var buckets = Array(repeating: 0, count: 9)
    numbers.forEach { number in
        buckets[number] += 1
    }
    for _ in (1...256) {
        var copy = Array(repeating: 0, count: 9)
        copy[8] = buckets[0]
        copy[7] = buckets[8]
        copy[6] = buckets[7] + buckets[0]
        copy[5] = buckets[6]
        copy[4] = buckets[5]
        copy[3] = buckets[4]
        copy[2] = buckets[3]
        copy[1] = buckets[2]
        copy[0] = buckets[1]
        buckets = copy
    }
    return buckets.reduce(0, +)
}
