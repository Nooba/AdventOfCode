//
//  day5.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 08/06/2022.
//

import Foundation

fileprivate struct Line {
    struct Point {
        let x: Int
        let y: Int

        init(string: String) throws {
            let components = string.components(separatedBy: ",")
            guard components.count == 2 else {
                throw AoCError.wrongFormat
            }
            let xString = components[0]
            let yString = components[1]
            guard let x = Int(xString),
                  let y = Int(yString) else {
                throw AoCError.wrongFormat
            }
            self.x = x
            self.y = y
        }
    }

    let startPoint: Point
    let endPoint: Point

    init(string: String) throws {
        let components = string.components(separatedBy: " -> ")
        guard components.count == 2 else {
            throw AoCError.wrongFormat
        }
        startPoint = try Point(string: components[0])
        endPoint = try Point(string: components[1])
    }

    var maxX: Int {
        return max(startPoint.x, endPoint.x)
    }

    var maxY: Int {
        return max(startPoint.y, endPoint.y)
    }

    var isVertical: Bool {
        return startPoint.x == endPoint.x
    }

    var isHorizontal: Bool {
        return startPoint.y == endPoint.y
    }
}

fileprivate struct Board {
    let content: [[Int]]

    var dangerousCount: Int {
        return content.reduce(into: 0) { partialResult, row in
            partialResult += row.filter { $0 >= 2 }.count
        }
    }

    var description: String {
        let rows = content.map { row -> String in
            let mapped = row.map { number -> String in
                number == 0 ? "." : "\(number)"
            }
            return mapped.joined()
        }
        return rows.joined(separator: "\n")
    }
}

func day5_A() throws -> Int {
    let lines = try FileReader(filename: "day5_input").getLines()
        .map { try Line(string: $0) }
    let maxX = lines.map { $0.maxX }.max()!
    let maxY = lines.map { $0.maxY }.max()!
    let rowArray = Array(repeating: 0, count: maxX + 1)
    var map = Array(repeating: rowArray, count: maxY + 1)
    lines.forEach { line in
//        print("\(line.startPoint), \(line.endPoint)")
        switch (line.isHorizontal, line.isVertical) {
        case (true, _):
            var row = map[line.startPoint.y]
            let min = min(line.startPoint.x, line.endPoint.x)
            let max = max(line.startPoint.x, line.endPoint.x)
            (min...max).forEach { index in
                row[index] += 1
            }
            map[line.startPoint.y] = row
        case (false, true):
            let min = min(line.startPoint.y, line.endPoint.y)
            let max = max(line.startPoint.y, line.endPoint.y)
            (min...max).forEach { index in
                var currentRow = map[index]
                currentRow[line.startPoint.x] += 1
                map[index] = currentRow
            }
        case (false, false):
            return
        }
//        print(Board(content: map).description)
//        print("\n")
    }
    return Board(content: map).dangerousCount
}

func day5_B() throws -> Int {
    let lines = try FileReader(filename: "day5_input").getLines()
        .map { try Line(string: $0) }
    let maxX = lines.map { $0.maxX }.max()!
    let maxY = lines.map { $0.maxY }.max()!
    let rowArray = Array(repeating: 0, count: maxX + 1)
    var map = Array(repeating: rowArray, count: maxY + 1)
    lines.forEach { line in
//        print("\(line.startPoint), \(line.endPoint)")
        switch (line.isHorizontal, line.isVertical) {
        case (true, _):
            var row = map[line.startPoint.y]
            let min = min(line.startPoint.x, line.endPoint.x)
            let max = max(line.startPoint.x, line.endPoint.x)
            (min...max).forEach { index in
                row[index] += 1
            }
            map[line.startPoint.y] = row
        case (false, true):
            let min = min(line.startPoint.y, line.endPoint.y)
            let max = max(line.startPoint.y, line.endPoint.y)
            (min...max).forEach { index in
                var currentRow = map[index]
                currentRow[line.startPoint.x] += 1
                map[index] = currentRow
            }
        case (false, false):
            let dx = line.endPoint.x > line.startPoint.x ? 1 : -1
            let dy = line.endPoint.y > line.startPoint.y ? 1 : -1
            var stepCounter = abs(line.startPoint.x - line.endPoint.x)
            var i = line.startPoint.x
            var j = line.startPoint.y
            while stepCounter >= 0 {
                var currentRow = map[j]
                currentRow[i] += 1
                map[j] = currentRow
                i += dx
                j += dy
                stepCounter -= 1
            }
        }
//        print(Board(content: map).description)
//        print("\n")
    }
    return Board(content: map).dangerousCount
}
