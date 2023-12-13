//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private class Map {
    enum Node: String {
        case ash = "."
        case rock = "#"
    }

    struct Row {
        let nodes: [Node]

        init(string: String) throws{
            nodes = string.compactMap { Node(rawValue: String($0)) }
            guard nodes.count == string.count else { throw AoCError.wrongFormat }
        }
    }

    let rows: [Row]
    var memoizedColumn: [Int: [Node]] = [:]

    func getColumn(at index: Int) -> [Node] {
        if let column = memoizedColumn[index] {
            return column
        }
        let column = rows.map { $0.nodes[index] }
        memoizedColumn[index] = column
        return column
    }

    var xCount: Int {
        return rows[0].nodes.count
    }

    var yCount: Int {
        return rows.count
    }

    init(mapString: [String]) throws {
        rows = try mapString.map { try Row(string: $0) }
    }
}

private func process(map: Map) throws -> Int {
    let maxYIndex = map.yCount
    let foundMirrorVerticalIndex = (1..<maxYIndex).first { verticalIndex in
        let maximumSizeConsidered = map.yCount / 2
        let actualHalfSize = verticalIndex > maximumSizeConsidered
        ? map.yCount - verticalIndex
        : verticalIndex
//        print("Vindex: \(verticalIndex), size: \(actualHalfSize)")
        return (1...actualHalfSize).allSatisfy { currentIndex in
            let leftRowIndex = verticalIndex - currentIndex
            let rightRowIndex = verticalIndex + currentIndex - 1
//            print("check row \(leftRowIndex) vs \(rightRowIndex)")
            return map.rows[leftRowIndex].nodes == map.rows[rightRowIndex].nodes
        }
    }
    if let foundMirrorVerticalIndex {
        return foundMirrorVerticalIndex * 100
    }
    let maxXIndex = map.xCount
    guard let foundMirrorHorizontalIndex = ((1..<maxXIndex).first { horizontalIndex in
        let maximumSizeConsidered = map.xCount / 2
        let actualHalfSize = horizontalIndex > maximumSizeConsidered
        ? map.xCount - horizontalIndex
        : horizontalIndex
//        print("Hindex: \(horizontalIndex), size: \(actualHalfSize)")
        return (1...actualHalfSize).allSatisfy { currentIndex in
            let leftColumnIndex = horizontalIndex - currentIndex
            let rightColumnIndex = horizontalIndex + currentIndex - 1
//            print("check column \(leftColumnIndex) vs \(rightColumnIndex)")
            return map.getColumn(at: leftColumnIndex) == map.getColumn(at: rightColumnIndex)
        }
    }) else {
        throw AoCError.resultNotFound
    }
    return foundMirrorHorizontalIndex
}

func day13_2023_A() throws -> Int {
    let groupedLines = try FileReader(filename: "day13_2023_input").getGroupedLines()
    let maps = try groupedLines.map { try Map(mapString: $0) }
    let results = try maps.map(process(map:))
    return results.reduce(0, +)
}

// MARK: - Part 2

func day13_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day13_2023_example").getLines()
    return -1
}
