//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private struct Row: CustomStringConvertible {
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
        record = components[1].components(separatedBy: ",").compactMap { Int(String($0)) }
    }

    private init(springs: [Status], record: [Int]) {
        self.springs = springs
        self.record = record
    }

    func copy(springs: [Status]) -> Row {
        return Row(springs: springs, record: self.record)
    }

    var isComplete: Bool {
        return springs.allSatisfy { $0 != .unknown }
    }

    var description: String {
        return springs.description
    }
}

// Useless bruteforce
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

// Useless bruteforce
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

// Useless bruteforce
private func processBruteforce(_ line: String) throws -> Int {
    let row = Row(string: line)
    let possibilities = generatePossibleRows(from: row.springs)
    return try possibilities.filter { try check(row: $0, versus: row.record) }.count
}

private func generateNextRowsToCheck(from row: Row) -> [Row] {
    guard let firstUnknownIndex = row.springs.firstIndex (where: { $0 == .unknown }) else {
        return []
    }
    var replacedWithBroken = row.springs
    replacedWithBroken[firstUnknownIndex] = .damaged
    var replacedWithGood = row.springs
    replacedWithGood[firstUnknownIndex] = .operational
    return [row.copy(springs: replacedWithGood), row.copy(springs: replacedWithBroken)]
}

private func removeInvalid(row: [Row.Status], versus record: [Int]) throws -> Bool {
//    print("testing \(row))")
//    print("…")
    let components = row.map { $0.rawValue }.joined().components(separatedBy: "?")
    let isFinalCheck = components.count == 1
    let componentsToCheck = components[0]
    let isLastMalleable = !isFinalCheck && componentsToCheck.hasSuffix("#")
    let brokenGroupsPreFilter = componentsToCheck.components(separatedBy: ".")
    let brokenGroups = brokenGroupsPreFilter.filter { $0.count > 0 }
    if brokenGroups.count > record.count {
        return false
    }
    if isFinalCheck && brokenGroups.count != record.count {
//        print("invalid, not matching amount of subgroups \(row)")
        return false
    }
    let check = zip(brokenGroups, record).enumerated().allSatisfy { (index, arg1) in
        let (group, count) = arg1
        return (index == brokenGroups.count - 1 && isLastMalleable)
        ? group.count <= count
        : group.count == count
    }
//    if check {
//        print("valid configuration: \(row)")
//    } else {
//        print("invalid: \(row)")
//    }
//    print("__")
    return check
}


private func setNextValueAndFilterInvalid(from rows: [Row]) throws -> [Row] {
    let nextRows = rows.flatMap { generateNextRowsToCheck(from: $0) }
    return try nextRows.filter { try removeInvalid(row: $0.springs, versus: $0.record) }
}

private func process(_ line: String) throws -> Int {
    let row = Row(string: line)
//    print(row.record)
    var results: [Row] = []
    var nextRows = try setNextValueAndFilterInvalid(from: [row])
    while !nextRows.isEmpty {
        let rowsToComputeNext = try setNextValueAndFilterInvalid(from: nextRows)
        if rowsToComputeNext.isEmpty {
            results.append(contentsOf: nextRows)
        }
        nextRows = rowsToComputeNext
    }
//    print(results)
    return results.count
}

func day12_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day12_2023_input").getLines()
    let results = try lines.enumerated().map { (index, element) in
//        print("-------")
//        print(index)
        return try process(element)
    }
//    print(results)
    return results.reduce(0, +)
}

// MARK: - Part 2

func day12_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day12_2023_example").getLines()
    return -1
}
