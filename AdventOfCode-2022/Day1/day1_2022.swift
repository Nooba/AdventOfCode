//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

func day1_2022_A() throws -> Int {
    let groupedLines = try FileReader(filename: "day1_2022_input").getGroupedLines()
    let elves = groupedLines.reduce(into: [Int]()) { partialResult, new in
        let elf = new.reduce(into: 0) { partialResult, string in
            let int = Int(string)!
            partialResult += int
        }
        partialResult.append(elf)
    }
    return elves.max()!
}

func day1_2022_B() throws -> Int {
    let groupedLines = try FileReader(filename: "day1_2022_input").getGroupedLines()
    let elves = groupedLines.reduce(into: [Int]()) { partialResult, new in
        let elf = new.reduce(into: 0) { partialResult, string in
            let int = Int(string)!
            partialResult += int
        }
        partialResult.append(elf)
    }
    return elves.sorted().reversed().prefix(upTo: 3).reduce(0, +)
}
