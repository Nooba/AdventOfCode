//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private struct Row {
    enum Status: String, CustomStringConvertible {
        case unknown = "?"
        case damaged = "#"
        case operational = "."

        var description: String {
            rawValue
        }
    }

    let springs: [Status]
    let record: [Int]

    init(string: String) {
        let components = string.components(separatedBy: .whitespaces)
        springs = components[0].compactMap { Status(rawValue: String($0)) }
        record = components[1].compactMap { Int(String($0)) }
    }
}

private func check(row: [Row.Status], versus record: [Int]) throws -> Bool {
    guard row.allSatisfy ({ $0 != .unknown} ) else { throw AoCError.wrongFormat}
    let brokenGroups = row.map { $0.rawValue }.joined().components(separatedBy: ".").filter { $0.count > 0 }
    guard brokenGroups.count == record.count else { return false }
    let check = zip(brokenGroups, record).allSatisfy { (group, count) in
        group.count == count
    }
//    if check {
//        print("valid configuration: \(row)")
//    }
    return check
}

private func generatePossibleRows(from row: [Row.Status]) -> [[Row.Status]] {
    guard let firstUnknownIndex = row.firstIndex (where: { $0 == .unknown }) else {
        return [row]
    }
    var replacedWithBroken = row
    replacedWithBroken[firstUnknownIndex] = .damaged
    var replacedWithGood = row
    replacedWithGood[firstUnknownIndex] = .operational
    return generatePossibleRows(from: replacedWithBroken) + generatePossibleRows(from: replacedWithGood)
}

private func process(_ line: String) throws -> Int {
    let row = Row(string: line)
    let possibilities = generatePossibleRows(from: row.springs)
    return try possibilities.filter { try check(row: $0, versus: row.record) }.count
}

func day12_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day12_2023_input").getLines()
    let results = try lines.map(process(_:))
    print(results)
    return results.reduce(0, +)
}

// MARK: - Part 2

func day12_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day12_2023_example").getLines()
    return -1
}
