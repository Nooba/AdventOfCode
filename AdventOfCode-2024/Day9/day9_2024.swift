//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation
import Algorithms

private struct Block: CustomDebugStringConvertible {
    var debugDescription: String {
        guard let id = fileId else { return "." }
        return "\(id)"
    }

    let fileId: Int?

    var isEmptyMemory: Bool {
        return fileId == nil
    }
}

private func parseLine(_ line: String) -> [Block] {
    var nextIsFile = true
    var fileId = 0
    var result = [Block]()
    line.forEach { char in
        let int = Int(String(char))!
        for _ in (0..<int) {
            result.append(Block(fileId: nextIsFile ? fileId : nil))
        }
        nextIsFile.toggle()
        if nextIsFile { fileId += 1 }

    }
    return result
}

private func process(_ left: Int, _ right: Int) -> (Int, Int)? {
//    print("left: \(left), right: \(right)")
    var leftIndex = left
    var leftBlock = memory[safe: leftIndex]
    while let lBlock = leftBlock, !lBlock.isEmptyMemory {
        leftIndex += 1
        leftBlock = memory[safe: leftIndex]
    }

    var rightIndex = right
    var rightBlock = memory[safe: rightIndex]
    while let rBlock = rightBlock, rBlock.isEmptyMemory {
        rightIndex -= 1
        rightBlock = memory[safe: rightIndex]
    }
    guard
        leftIndex < rightIndex else {
        return nil
    }
    let temp = memory[leftIndex]
    memory[leftIndex] = memory[rightIndex]
    memory[rightIndex] = temp
    return (leftIndex, rightIndex)
}

private var memory = [Block]()

func day9_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day9_2024_input").getLines()
    memory = parseLine(lines[0])
//    print(memory)
    var tuple: (Int, Int)? = (0, memory.count - 1)
    while tuple != nil {
//        print(memory)
        tuple = process(tuple!.0, tuple!.1)
    }
    return memory.enumerated().reduce(0) { partialResult, iterator in
        let (index, block) = iterator
        guard !block.isEmptyMemory else { return partialResult }
        return partialResult + index * block.fileId!
    }
}

// MARK: - Part B

func day9_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day9_2024_input").getLines()
    let memory = parseLine(lines[0])
    print(memory)
    return -1
}
