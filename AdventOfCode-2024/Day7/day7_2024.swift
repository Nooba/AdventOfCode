//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation

private class Test {
    let target: Int
    let numbers: [Int]
    var isValid: Bool

    init(target: Int, numbers: [Int], isValid: Bool) {
        self.target = target
        self.numbers = numbers
        self.isValid = isValid
    }

    func process() {
        isValid = test(target: target, numbers: numbers)
    }

    // MARK: - Private

    private func test(target: Int, numbers: [Int]) -> Bool {
        guard numbers.count >= 2 else {
            return numbers[0] == target
        }
        let newAfterAddition = numbers[0] + numbers[1]
        var additionTest = false
        if newAfterAddition <= target {
            var copy = Array(numbers.dropFirst(2))
            copy.insert(newAfterAddition, at: 0)
            additionTest = test(target: target, numbers: copy)
        }
        guard !additionTest else { return true }

        var multiplicationTest = false
        let newAfterMultiplication = numbers[0] * numbers[1]
        if newAfterMultiplication <= target {
            var copy = Array(numbers.dropFirst(2))
            copy.insert(newAfterMultiplication, at: 0)
            multiplicationTest = test(target: target, numbers: Array(copy))
        }
        return multiplicationTest
    }
}

private func parseLine(_ line: String) -> Test {
    let components = line.components(separatedBy: ":")
    let target = Int(components[0])!
    let numbers = components[1].trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ").map { Int($0)! }
    return Test(target: target, numbers: numbers, isValid: false)
}

func day7_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day7_2024_input").getLines()
    let tests = lines.map { parseLine($0) }
    tests.forEach { $0.process() }
    return tests.filter { $0.isValid }.map { $0.target }.reduce(0, +)
}

// MARK: - Part B

extension Test {
    func processSecondPart() {
        isValid = testSecondPart(target: target, numbers: numbers)
    }

    // MARK: - Private

    private func testSecondPart(target: Int, numbers: [Int]) -> Bool {
        guard numbers.count >= 2 else {
            return numbers[0] == target
        }
        let newAfterAddition = numbers[0] + numbers[1]
        var additionTest = false
        if newAfterAddition <= target {
            var copy = Array(numbers.dropFirst(2))
            copy.insert(newAfterAddition, at: 0)
            additionTest = testSecondPart(target: target, numbers: copy)
        }
        guard !additionTest else { return true }

        var multiplicationTest = false
        let newAfterMultiplication = numbers[0] * numbers[1]
        if newAfterMultiplication <= target {
            var copy = Array(numbers.dropFirst(2))
            copy.insert(newAfterMultiplication, at: 0)
            multiplicationTest = testSecondPart(target: target, numbers: Array(copy))
        }
        guard !multiplicationTest else { return true }

        var concatenationTest = false
        let newAfterConcatenation = Int("\(numbers[0])\(numbers[1])")!
        if newAfterConcatenation <= target {
            var copy = Array(numbers.dropFirst(2))
            copy.insert(newAfterConcatenation, at: 0)
            concatenationTest = testSecondPart(target: target, numbers: Array(copy))
        }

        return concatenationTest
    }
}

func day7_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day7_2024_input").getLines()
    let tests = lines.map { parseLine($0) }
    tests.forEach { $0.processSecondPart() }
//    print(tests.filter { $0.isValid }.map { $0.target })
    return tests.filter { $0.isValid }.map { $0.target }.reduce(0, +)
}
