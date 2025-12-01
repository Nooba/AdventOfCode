//
//  day1_2025.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2025.
//

import Foundation

private func parseDictionaryLine(_ line: String) throws -> Pair {
    let components = line.components(separatedBy: "|").map { Int($0)! }
    return Pair(first: components[0], last: components[1])
}

private func testUpdate(line: String, rules: Set<Pair>) -> Int {
    let pages = line.components(separatedBy: ",").map { Int($0)! }
    var printedPages = Set<Int>()
    var isGood = true
    pages.forEach { page in
        guard isGood else { return }
        let rulesToApply = rules.filter { $0.last == page }
        if rulesToApply.count == 0 {
            printedPages.insert(page)
            return
        }
        if (rulesToApply.allSatisfy { pair in
            if pages.contains(pair.first) {
                return printedPages.contains(pair.first)
            }
            return true
        }) {
            printedPages.insert(page)
            return
        }
        isGood = false
    }
    if isGood {
        return pages[pages.count / 2]
    }
    return 0
}

private struct Pair: Hashable {
    let first: Int
    let last: Int
}

func day5_2025_A() throws -> Int {
    let lines = try FileReader(filename: "day5_2025_input").getGroupedLines()
    let pairs = try lines[0].map { try parseDictionaryLine($0)}
    let rules = Set<Pair>(pairs)
    let results = lines[1].map { testUpdate(line: $0, rules: rules) }
    return results.reduce(0, +)
}

// MARK: - Part B

private func fixUpdateThroughReorder(line: String, orderedRules: [Pair]) -> Int {
    let pages = line.components(separatedBy: ",").map { Int($0)! }
    var printedPages = Set<Int>()
    var newPages = [Int]()
    var isDone = false
//    print(pages)
    while newPages.count < pages.count {
        let nextPage = pages.first { page in
            guard !newPages.contains(page) else { return false }
            return orderedRules.allSatisfy { $0.last != page || newPages.contains($0.first) || !pages.contains($0.first) }
        }
        newPages.append(nextPage!)
//        print(newPages)
    }
    return newPages[newPages.count / 2]
}

func day5_2025_B() throws -> Int {
    let lines = try FileReader(filename: "day5_2025_input").getGroupedLines()
    let pairs = try lines[0].map { try parseDictionaryLine($0) }
    let rules = Set<Pair>(pairs)
    let wronglyOrdered = lines[1].filter { testUpdate(line: $0, rules: rules) == 0 }
    let results = wronglyOrdered.map { fixUpdateThroughReorder(line: $0, orderedRules: pairs) }
//    print(results)
    return results.reduce(0, +)

}
