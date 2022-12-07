//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

func day2_2022_A() throws -> Int {
    let lines = try FileReader(filename: "day2_2022_input").getLines()
    let split: [[String]] = lines.map { $0.components(separatedBy: .whitespaces) }
    let result = split.reduce(into: 0) { partialResult, round in
        switch round[1] {
        case "X":
            partialResult += 1
        case "Y":
            partialResult += 2
        case "Z":
            partialResult += 3
        default:
            fatalError()
        }
        switch (round[0], round[1]) {
        case ("A", "Z"), ("B", "X"), ("C", "Y"): // loss
            partialResult += 0
        case ("A", "Y"), ("B", "Z"), ("C", "X"): // win
            partialResult += 6
        case ("A", "X"), ("B", "Y"), ("C", "Z"): // draw
            partialResult += 3
        default:
            fatalError()
        }
    }
    return result
}

func day2_2022_B() throws -> Int {
    let lines = try FileReader(filename: "day2_2022_input").getLines()
    let split: [[String]] = lines.map { $0.components(separatedBy: .whitespaces) }
    let result = split.reduce(into: 0) { partialResult, round in
        switch (round[0], round[1]) {
        case ("A", "Z"): // win - play paper
            partialResult += 6 + 2
        case ("B", "X"): // lose - play rock
            partialResult += 0 + 1
        case ("C", "Y"): // draw - play scissors
            partialResult += 3 + 3
        case ("A", "Y"): // draw - play rock
            partialResult += 3 + 1
        case ("B", "Z"): // win - play scissors
            partialResult += 6 + 3
        case ("C", "X"): // lose - play paper
            partialResult += 0 + 2
        case ("A", "X"): // lose - play scissors
            partialResult += 0 + 3
        case ("B", "Y"): // draw - play paper
            partialResult += 3 + 2
        case ("C", "Z"): // win - play rock
            partialResult += 6 + 1
        default:
            fatalError()
        }
    }
    return result
}
