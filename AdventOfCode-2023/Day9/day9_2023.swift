//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private func parseLine(_ line: String) -> [Int] {
    return line.components(separatedBy: .whitespaces).compactMap { Int($0) }
}

private func process(_ data: [Int]) -> Int {
    var steps: [[Int]] = [data]
    var currentStep = data
    while !currentStep.allSatisfy({ $0 == 0 }) {
        let nextStep = currentStep.enumerated().compactMap { (index, element) -> Int? in
            guard index > 0 else { return nil }
            return element - currentStep[index - 1]
        }
        steps.append(nextStep)
        currentStep = nextStep
    }
    stride(from: steps.count - 2, to: -1, by: -1).forEach { index in
        var current = steps[index]
        let next = steps[index + 1]
        current.append(current.last! + next.last!)
        steps[index] = current
    }
    print(steps)
    return steps.first!.last!
}

func day9_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day9_2023_input").getLines()
    let inputs = lines.map(parseLine(_:))
    return inputs.map(process(_:)).reduce(0, +)
}

// MARK: - Part 2

private func parseLineSecondPart(_ line: String) -> [Int] {
    return parseLine(line).reversed()
}

private func processSecondPart(_ data: [Int]) -> Int {
    var steps: [[Int]] = [data]
    var currentStep = data
    while !currentStep.allSatisfy({ $0 == 0 }) {
        let nextStep = currentStep.enumerated().compactMap { (index, element) -> Int? in
            guard index > 0 else { return nil }
            return currentStep[index - 1] - element
        }
        steps.append(nextStep)
        currentStep = nextStep
    }
    stride(from: steps.count - 2, to: -1, by: -1).forEach { index in
        var current = steps[index]
        let next = steps[index + 1]
        current.append(current.last! - next.last!)
        steps[index] = current
    }
    return steps.first!.last!
}

func day9_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day9_2023_input").getLines()
    let inputs = lines.map(parseLineSecondPart(_:))
    return inputs.map(processSecondPart(_:)).reduce(0, +)
}
