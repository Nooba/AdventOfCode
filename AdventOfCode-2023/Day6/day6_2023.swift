//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

private func parse(times: String, distances: String) throws -> ([Int], [Int]) {
    let timeValues = times.components(separatedBy: CharacterSet.whitespaces).compactMap { Int($0) }
    let distanceValues = distances.components(separatedBy: CharacterSet.whitespaces).compactMap { Int($0) }
    guard timeValues.count == distanceValues.count else { throw AoCError.wrongFormat }
    return (timeValues, distanceValues)
}

private func process(time: Int, distance: Int) throws -> Int {
    // find min such that we win
    let minHold = (0..<time).first { holdDown in
        holdDown * (time - holdDown) > distance
    }
    // find max such that we win
    let maxHold = stride(from: time, to: 0, by: -1).first { holdDown in
        holdDown * (time - holdDown) > distance
    }
    guard let minHold, let maxHold else { throw AoCError.resultNotFound }
    return maxHold - minHold + 1
}

func day6_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day6_2023_input").getLines()
    let (times, distances) = try parse(times: lines[0], distances: lines[1])
    return try (0..<times.count).map { try process(time: times[$0], distance: distances[$0]) }.reduce(1, *)
}

private func parseSecondPart(times: String, distances: String) throws -> (Int, Int) {
    let time = Int(times.components(separatedBy: ":")[1].components(separatedBy: CharacterSet.whitespaces).joined())!
    let distance = Int(distances.components(separatedBy: ":")[1].components(separatedBy: CharacterSet.whitespaces).joined())!
    return (time, distance)
}

func day6_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day6_2023_input").getLines()
    let (time, distance) = try parseSecondPart(times: lines[0], distances: lines[1])
    return try process(time: time, distance: distance)
}
