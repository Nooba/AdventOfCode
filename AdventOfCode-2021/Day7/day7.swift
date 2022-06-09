//
//  day7.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 09/06/2022.
//

import Foundation

func day7_A() throws -> Int {
    let line = try FileReader(filename: "day7_input").getLines().first!
    let numberStrings = line.components(separatedBy: ",")
    let numbers = try numberStrings.map { string -> Int in
        guard let number = Int(string) else {
            throw AoCError.wrongFormat
        }
        return number
    }
    let min = numbers.min()!
    let max = numbers.max()!
    var minPosition = min
    var minDistance = Int.max
    for i in min...max {
        let distance = numbers.reduce(into: 0) { partialResult, number in
            partialResult += abs(number - i)
        }
        if distance < minDistance {
            minDistance = distance
            minPosition = i
        }
    }
    return minDistance
}

func day7_B() throws -> Int {
    let line = try FileReader(filename: "day7_input").getLines().first!
    let numberStrings = line.components(separatedBy: ",")
    let numbers = try numberStrings.map { string -> Int in
        guard let number = Int(string) else {
            throw AoCError.wrongFormat
        }
        return number
    }
    let min = numbers.min()!
    let max = numbers.max()!
    var minPosition = min
    var minDistance = Int.max
    for i in min...max {
        let distance = numbers.reduce(into: 0) { partialResult, number in
            let steps = abs(number - i)
            let distance = steps * (steps + 1) / 2
            partialResult += distance
        }
        if distance < minDistance {
            minDistance = distance
            minPosition = i
        }
    }
    return minDistance
}
