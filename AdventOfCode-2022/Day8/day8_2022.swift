//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

private struct Map {
    var rows: [Row]

    init(_ lines: [String]) throws {
        rows = try lines.map { try Row($0) }
    }

    var visibleTreesCount: Int {
        return rows.reduce(into: 0) { partialResult, row in
            partialResult += row.visibleTreesCount
        }
    }

    mutating func processAndReturnVisibility() throws -> Int {
        let newRows = try rows.enumerated().map { (rowIndex, row) -> Row in
            let newTrees = try row.trees.enumerated().map { (columnIndex, column) -> Tree in
                return try processTreeVisibility(x: rowIndex, y: columnIndex)
            }
            return Row(trees: newTrees)
        }
        rows = newRows
        return visibleTreesCount
    }

    mutating func processTreeVisibility(x: Int, y: Int) throws -> Tree {
        guard let currentTree = tree(x: x, y: y) else {
            throw AoCError.wrongFormat
        }
        let hasVisibleDirection = [Direction.Top, .Left, .Bottom, .Right].first { direction in
            let candidates = allTrees(from: x, y: y, direction: direction)
            guard !candidates.isEmpty else {
                // edgeTree
                return true
            }
            return candidates.allSatisfy { $0.height < currentTree.height }
        }
        return Tree(height: currentTree.height, isVisible: hasVisibleDirection != nil)
    }

    private enum Direction {
        case Top, Left, Right, Bottom
    }

    private func allTrees(from x: Int, y: Int, direction: Direction) -> [Tree] {
        switch direction {
        case .Left:
            return stride(from: y-1, through: 0, by: -1).compactMap { currentY in
                tree(x: x, y: currentY)
            }
        case .Top:
            return stride(from: x-1, through: 0, by: -1).compactMap { currentX in
                tree(x: currentX, y: y)
            }
        case .Bottom:
            return stride(from: x+1, through: rows[0].trees.count, by: 1).compactMap { currentX in
                tree(x: currentX, y: y)
            }
        case .Right:
            return stride(from: y+1, to: rows.count, by: 1).compactMap { currentY in
                tree(x: x, y: currentY)
            }
        }
    }

    func tree(x: Int, y: Int) -> Tree? {
        return rows[safe: x]?.trees[safe: y]
    }

}

private struct Row {
    let trees: [Tree]

    var visibleTreesCount: Int {
        return trees.filter { $0.isVisible }.count
    }

    init(trees: [Tree]) {
        self.trees = trees
    }

    init(_ line: String) throws {
        let chars = Array(line).map { String($0) }
        trees = try chars.map { try Tree($0) }
    }
}

private struct Tree {
    let height: Int
    var scenicValue: Int
    var isVisible: Bool

    init(height: Int, isVisible: Bool) {
        self.height = height
        self.scenicValue = -1
        self.isVisible = isVisible
    }

    init(height: Int, scenicValue: Int, isVisible: Bool) {
        self.height = height
        self.scenicValue = scenicValue
        self.isVisible = isVisible
    }

    init(_ heightVal: String) throws {
        guard let height = Int(heightVal) else {
            throw AoCError.wrongFormat
        }
        self.height = height
        scenicValue = -1
        isVisible = true
    }
}

func day8_2022_A() throws -> Int {
    let lines = try FileReader(filename: "day8_2022_input").getLines()
    var map = try Map(lines)
    return try map.processAndReturnVisibility()
}

extension Map {

    var scenicValue: Int {
        let values = rows.flatMap { $0.trees.map { $0.scenicValue } }
        return values.max()!
    }

    mutating func processAndReturnScenicValue() throws -> Int {
        let newRows = try rows.enumerated().map { (rowIndex, row) -> Row in
            let newTrees = try row.trees.enumerated().map { (columnIndex, column) -> Tree in
                return try processTreeScenicValue(x: rowIndex, y: columnIndex)
            }
            return Row(trees: newTrees)
        }
        rows = newRows
        return scenicValue
    }

    mutating func processTreeScenicValue(x: Int, y: Int) throws -> Tree {
        guard let currentTree = tree(x: x, y: y) else {
            throw AoCError.wrongFormat
        }
        let scenicValues = [Direction.Top, .Left, .Bottom, .Right].map { direction -> Int in
            let visible = allVisibleTrees(height: currentTree.height, x: x, y: y, direction: direction)
            return visible.count
        }
        let scenicValue = scenicValues.reduce(1, *)
        return Tree(height: currentTree.height, scenicValue: scenicValue, isVisible: false)
    }

    private func allVisibleTrees(height: Int, x: Int, y: Int, direction: Direction) -> [Tree] {
        let maxHeight = height
        var keepGoing = true
        switch direction {
        case .Left:
            return stride(from: y-1, through: 0, by: -1).compactMap { currentY in
                guard keepGoing else { return nil }
                guard let nextTree = tree(x: x, y: currentY) else {
                    return nil
                }
                if nextTree.height >= maxHeight {
                    keepGoing = false
                }
                return nextTree
            }
        case .Top:
            return stride(from: x-1, through: 0, by: -1).compactMap { currentX in
                guard keepGoing else { return nil }
                guard let nextTree = tree(x: currentX, y: y) else {
                    return nil
                }
                if nextTree.height >= maxHeight {
                    keepGoing = false
                }
                return nextTree
            }
        case .Bottom:
            return stride(from: x+1, through: rows[0].trees.count, by: 1).compactMap { currentX in
                guard keepGoing else { return nil }
                guard let nextTree = tree(x: currentX, y: y) else {
                    return nil
                }
                if nextTree.height >= maxHeight {
                    keepGoing = false
                }
                return nextTree
            }
        case .Right:
            return stride(from: y+1, to: rows.count, by: 1).compactMap { currentY in
                guard keepGoing else { return nil }
                guard let nextTree = tree(x: x, y: currentY) else {
                    return nil
                }
                if nextTree.height >= maxHeight {
                    keepGoing = false
                }
                return nextTree
            }
        }
    }
}

func day8_2022_B() throws -> Int {
    let lines = try FileReader(filename: "day8_2022_input").getLines()
    var map = try Map(lines)
    return try map.processAndReturnScenicValue()
}
