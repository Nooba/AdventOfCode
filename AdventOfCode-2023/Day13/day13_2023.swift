//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private class Map {
    enum Node: String, CustomStringConvertible {
        case ash = "."
        case rock = "#"

        var description: String { return rawValue }
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

    func getColumns(in range: ClosedRange<Int>) -> [[Node]] {
        return range.map { index in
            getColumn(at: index)
        }
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
            let topRowIndex = verticalIndex - currentIndex
            let bottomRowIndex = verticalIndex + currentIndex - 1
//            print("check row \(leftRowIndex) vs \(rightRowIndex)")
            return map.rows[topRowIndex].nodes == map.rows[bottomRowIndex].nodes
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

private struct MapSlice: Equatable {

    let slice: [[Map.Node]]

    static func == (lhs: MapSlice, rhs: MapSlice) -> Bool {
        var differencesCount = 0
        guard lhs.slice.count == rhs.slice.count else { return false }
        (0..<lhs.slice.count).forEach { index in
            if differencesCount > 1 { return }
            differencesCount += zip(lhs.slice[index], rhs.slice[index]).reduce(into: 0) { (partialResult, arg1) in
                let (leftNode, rightNode) = arg1
                partialResult += leftNode == rightNode ? 0 : 1
            }
        }
//        print("lhs:\n\(lhs.slice)")
//        print("rhs:\n\(rhs.slice)")
//        print("diffCount \(differencesCount)")
        return differencesCount == 1
    }

}

private func processSecondPart(map: Map) throws -> Int {
    let maxYIndex = map.yCount
    let foundMirrorVerticalIndex = (1..<maxYIndex).first { verticalIndex in
        let maximumSizeConsidered = map.yCount / 2
        let actualHalfSize = verticalIndex > maximumSizeConsidered
        ? map.yCount - verticalIndex
        : verticalIndex
//        print("Vindex: \(verticalIndex), size: \(actualHalfSize)")
        let minTop = min(verticalIndex-1, verticalIndex - actualHalfSize)
        let maxTop = max(verticalIndex-1, verticalIndex - actualHalfSize)
//        print("sliceTop: \(minTop)-\(maxTop)")
        let topSliceRows = map.rows[minTop...maxTop]
        let topSlice = MapSlice(slice: Array(topSliceRows).map { $0.nodes })
        let minBottom = min(verticalIndex, verticalIndex + actualHalfSize - 1)
        let maxBottom = max(verticalIndex, verticalIndex + actualHalfSize - 1)
//        print("sliceBottom: \(minBottom)-\(maxBottom)")
        let bottomSliceRows = map.rows[minBottom...maxBottom].reversed()
        let bottomSlice = MapSlice(slice: Array(bottomSliceRows).map { $0.nodes })
        return topSlice == bottomSlice
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
        let minLeft = min(horizontalIndex-1, horizontalIndex - actualHalfSize)
        let maxLeft = max(horizontalIndex-1, horizontalIndex - actualHalfSize)
//        print("sliceLeft: \(minLeft)-\(maxLeft)")
        let leftSlice = MapSlice(slice: map.getColumns(in: (minLeft...maxLeft)))
        let minRight = min(horizontalIndex, horizontalIndex + actualHalfSize - 1)
        let maxRight = max(horizontalIndex, horizontalIndex + actualHalfSize - 1)
//        print("sliceRight: \(minRight)-\(maxRight)")
        let rightSlice = MapSlice(slice: map.getColumns(in: (minRight...maxRight)).reversed())
        return leftSlice == rightSlice
    }) else {
        throw AoCError.resultNotFound
    }
    return foundMirrorHorizontalIndex
}



func day13_2023_B() throws -> Int {
    let groupedLines = try FileReader(filename: "day13_2023_input").getGroupedLines()
    let maps = try groupedLines.map { try Map(mapString: $0) }
    let results = try maps.map(processSecondPart(map:))
    return results.reduce(0, +)
}
