//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

private func fullyOverlap(left: (Int, Int), right: (Int, Int)) -> Bool {
    if left.0 <= right.0 && left.1 >= right.1 {
        // right included in left
        return true
    }
    if right.0 <= left.0 && right.1 >= left.1 {
        // left included in right
        return true
    }
    return false
}

private func overlapAtAll(left: (Int, Int), right: (Int, Int)) -> Bool {
    if left.0 < right.0 && left.1 < right.0 {
        return false
    }
    if left.0 > right.1 && left.1 > right.1 {
        return false
    }
    return true
}

private func tuples(from string: String) throws -> ((Int, Int), (Int, Int)) {
    let components = string.components(separatedBy: ",")
    guard components.count == 2 else {
        throw AoCError.wrongFormat
    }
    let leftComponents = components[0].components(separatedBy: "-")
    guard leftComponents.count == 2 else {
        throw AoCError.wrongFormat
    }
    let rightComponents = components[1].components(separatedBy: "-")
    guard rightComponents.count == 2 else {
        throw AoCError.wrongFormat
    }
    let leftTuple = (Int(leftComponents[0])!, Int(leftComponents[1])!)
    let rightTuple = (Int(rightComponents[0])!, Int(rightComponents[1])!)
    return (leftTuple, rightTuple)
}

func day4_2022_A() throws -> Int {
    let lines = try FileReader(filename: "day4_2022_input").getLines()
    let result = try lines.map { line -> Int in
        let tuples = try tuples(from: line)
        let overlap = fullyOverlap(left: tuples.0, right: tuples.1)
        return overlap ? 1 : 0
    }
    return result.reduce(0, +)
}

func day4_2022_B() throws -> Int {
    let lines = try FileReader(filename: "day4_2022_input").getLines()
    let result = try lines.map { line -> Int in
        let tuples = try tuples(from: line)
        let overlap = overlapAtAll(left: tuples.0, right: tuples.1)
        return overlap ? 1 : 0
    }
    return result.reduce(0, +)
}
