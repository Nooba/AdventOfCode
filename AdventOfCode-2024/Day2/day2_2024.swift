//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation

private func parseLine(_ line: String) throws -> [Int] {
    return (line.components(separatedBy: .whitespacesAndNewlines)).compactMap { Int($0) }
}

func day2_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day2_2024_input").getLines()
    let numbers = try lines.map(parseLine(_:))
    let mapped = numbers.map { line -> Bool in
        var positiveSlope: Bool?
        var previous: Int!
        var isSafe = true
        print(line)
        line.enumerated().forEach { (index, element) in
            if !isSafe { return }
            if index == 0 {
                previous = element
                return
            }
            print(element)
            if index == 1 {
                positiveSlope = element >= previous
            }
            let abs = abs(element - previous)
            if abs > 3 {
                print("distance")
                isSafe = false
                return
            }
            if abs == 0 {
                print("flat slope")
                isSafe = false
                return
            }
            if (element >= previous) != positiveSlope {
                print("slope change")
                isSafe = false
                return
            }
            previous = element
        }
        return isSafe
    }
    return mapped.filter { $0 }.count
}

func day2_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day2_2024_input").getLines()
    return -1
}
