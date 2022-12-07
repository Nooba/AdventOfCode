//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

func day6_2022_A() throws -> Int {
    let lines = try FileReader(filename: "day6_2022_input").getLines()
    let line = lines.first!
    let array = Array(line)
    let result = array.enumerated().first { (index, element) in
        guard index > 3 else {
            return false
        }
        let first = array[index - 3]
        let second = array[index - 2]
        let third = array[index - 1]
        return first != second
        && first != third
        && first != element
        && second != third
        && second != element
        && third != element
    }
    return result!.offset+1
}

private func checkAllDistincts(_ array: [String.Element]) -> Bool {
    let set = Set(array)
    return set.count == array.count
}

func day6_2022_B() throws -> Int {
    let lines = try FileReader(filename: "day6_2022_input").getLines()
    let line = lines.first!
    let array = Array(line)
    let result = array.enumerated().first { (index, element) in
        guard index > 13 else {
            return false
        }
        let slice = array[(index - 13)...index]
        let slicedArray = Array(slice)
        return checkAllDistincts(slicedArray)
    }
    return result!.offset+1
}
