//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation
import Algorithms


private class Stone: CustomStringConvertible {
    var value: Int
    var nextStone: Stone?

    init(value: Int, nextStone: Stone?) {
        self.value = value
        self.nextStone = nextStone
    }

    var description: String {
        return "Stone \(value), hasNext: \(nextStone != nil ? true : false)"
    }
}

private func parseLine(_ line: String) -> Stone {
    var previousStone: Stone?
    let rows = line.components(separatedBy: .whitespacesAndNewlines).map { string in
        let stone = Stone(value: Int(string)!, nextStone: nil)
        previousStone?.nextStone = stone
        previousStone = stone
        return stone
    }
    return rows.first!
}

private func blinkAllStones(startingAt stone: Stone?) {
    var currentStone: Stone? = stone
    while currentStone != nil {
        let nextStone: Stone? = currentStone!.nextStone
        blink(stone: currentStone)
        currentStone = nextStone
    }
}

private func blink(stone: Stone?) {
    guard let stone else { return }
    let nextStone = stone.nextStone
    if stone.value == 0 {
        stone.value += 1
        return
    }
    if let (leftValue, rightValue) = memoization[stone.value] {
        let rightStone = Stone(value: rightValue, nextStone: nextStone)
        stone.value = leftValue
        stone.nextStone = rightStone
        return
    }
    let intString = String(stone.value)
    if intString.count.isMultiple(of: 2) {
        let (leftString, rightString) = intString.splitStringInHalf()
        let (leftValue, rightValue) = (Int(leftString)!, Int(rightString)!)
        memoization[stone.value] = (leftValue, rightValue)
        let rightStone = Stone(value: rightValue, nextStone: nextStone)
        stone.value = leftValue
        stone.nextStone = rightStone
        return
    }
    stone.value *= 2024
    return
}

// adapted from https://stackoverflow.com/a/57074974/900937
private extension String {
   func splitStringInHalf() -> (String, String) {
       var str = self
       let halfLength = str.count / 2

       let index = str.index(str.startIndex, offsetBy: halfLength)
       str.insert("-", at: index)
       let result = str.split(separator: "-")
       return (String(result[0]), String(result[1]))
    }
}

private func countStones(_ start: Stone) -> Int {
    var count = 0
    var currentStone: Stone? = start
    while currentStone != nil {
        count += 1
        currentStone = currentStone!.nextStone
    }
    return count
}

func day11_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day11_2024_input").getLines()
    let stone = parseLine(lines[0])
    let amountOfBlink = 25
    for _ in 0..<amountOfBlink {
        blinkAllStones(startingAt: stone)
    }
    var buckets: [Int: Int] = [:]
    var currentStone: Stone? = stone
    while currentStone != nil {
        buckets[currentStone!.value] = (buckets[currentStone!.value] ?? 0) + 1
        currentStone = currentStone!.nextStone
    }
    return countStones(stone)
}

// MARK: - Part B

private var memoization: [Int: (Int, Int)] = [:]

private func parseLineB(_ line: String) -> [Int] {
    return line.components(separatedBy: .whitespacesAndNewlines).map { string in
        Int(string)!
    }
}

private func blinkBuckets() {
    var nextBuckets: [Int: Int] = [:]
    buckets.forEach { (key: Int, value: Int) in
        if key == 0 {
            nextBuckets[1] = (nextBuckets[1] ?? 0) + value
            return
        }
        if let (leftKey, rightKey) = memoization[key] {
            let leftValue = nextBuckets[leftKey] ?? 0
            nextBuckets[leftKey] = leftValue + value
            // !!! leftKey can be the same as rightKey. reread the value after inserting left.
            let rightValue = nextBuckets[rightKey] ?? 0
            nextBuckets[rightKey] = rightValue + value
            return
        }
        let intString = String(key)
        if intString.count.isMultiple(of: 2) {
            let (leftString, rightString) = intString.splitStringInHalf()
            let (leftKey, rightKey) = (Int(leftString)!, Int(rightString)!)
            let leftValue = nextBuckets[leftKey] ?? 0
            nextBuckets[leftKey] = leftValue + value
            // !!! leftKey can be the same as rightKey. reread the value after inserting left.
            let rightValue = nextBuckets[rightKey] ?? 0
            nextBuckets[rightKey] = rightValue + value
            memoization[key] = (leftKey, rightKey)
            return
        }
        nextBuckets[key * 2024] = (nextBuckets[key * 2024] ?? 0) + value
    }
    buckets = nextBuckets
}

private var buckets: [Int: Int] = [:]

func day11_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day11_2024_input").getLines()
    let values = parseLineB(lines[0])
    values.forEach { buckets[$0] = (buckets[$0] ?? 0) + 1 }
    let amountOfBlink = 75
    let start = Date()
    for i in 0..<amountOfBlink {
        blinkBuckets()
        let finish = Date()
        let durationString = String(format: "%.3f", start.distance(to: finish))
    }
    _ = try day11_2024_A()
    return buckets.values.reduce(0, +)


}
