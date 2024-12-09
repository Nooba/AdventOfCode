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
    var tuple: (Int, Int)? = (0, memory.count - 1)
    while tuple != nil {
        tuple = process(tuple!.0, tuple!.1)
    }
    return memory.enumerated().reduce(0) { partialResult, iterator in
        let (index, block) = iterator
        guard !block.isEmptyMemory else { return partialResult }
        return partialResult + index * block.fileId!
    }
}

// MARK: - Part B

private var moved = Set<Int>()

private func processSecondPart(_ fileStart: Int, _ fileEnd: Int) throws -> Int? {
    guard let fileId = memory[fileStart].fileId else { throw AoCError.wrongFormat }
    if moved.contains(fileId) {
        // Only move files once
        return fileStart - 1
    }
    moved.insert(fileId)
    let size = fileEnd - fileStart + 1
    guard let leftStart = findEmptyBloc(of: size, before: fileStart) else {
        // No found block for a swap
        return fileStart - 1
    }
    try swapMemory(
        leftStartIndex: leftStart,
        leftEndIndex: leftStart + size - 1,
        rightStartIndex: fileStart,
        rightEndIndex: fileEnd
    )
    guard fileStart > 0 else {
        return nil
    }
    return fileStart - 1
}

private func findEmptyBloc(of size: Int, before leftFileIndex: Int) -> Int? {
    var start = 0
    var result: Int?
    while result == nil, start <= leftFileIndex {
        if memory[start].isEmptyMemory {
            if memory[start..<(start+size)].allSatisfy({ $0.isEmptyMemory }) {
                result = start
            } else {
                start += 1
            }
        } else {
            start += 1
        }
    }
    return result
}

private func swapMemory(leftStartIndex: Int, leftEndIndex: Int, rightStartIndex: Int, rightEndIndex: Int) throws {
    let size = leftEndIndex-leftStartIndex + 1
    guard size == (rightEndIndex - rightStartIndex + 1) else { throw AoCError.wrongFormat }
    let temp = memory[leftStartIndex...leftEndIndex]
    (0..<size).forEach { index in
        memory[leftStartIndex + index] = memory[rightStartIndex + index]
        memory[rightStartIndex + index] = temp[leftStartIndex + index]
    }
}

func day9_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day9_2024_input").getLines()
    memory = parseLine(lines[0])
    var nextFileEnd = memory.lastIndex { !$0.isEmptyMemory }
    var nextFileStart = nextFileEnd
    while nextFileEnd != nil {
        // Ignore emptyMemory
        while memory[nextFileEnd!].isEmptyMemory || moved.contains(memory[nextFileEnd!].fileId!)  {
            guard nextFileEnd! > 0 else { break }
            nextFileEnd! -= 1
            nextFileStart = nextFileEnd
        }
        // We are on the end of the next file to process
        guard nextFileEnd! > 0 else { break }
        while memory[nextFileStart!].fileId == memory[nextFileEnd!].fileId {
            // Find its start
            nextFileStart! -= 1
            guard nextFileStart! > 0 else { break }
        }
        nextFileEnd = try processSecondPart(nextFileStart! + 1, nextFileEnd!)
        nextFileStart = nextFileEnd
//        print(memory)
    }
    return memory.enumerated().reduce(0) { partialResult, iterator in
        let (index, block) = iterator
        guard !block.isEmptyMemory else { return partialResult }
        return partialResult + index * block.fileId!
    }
}
