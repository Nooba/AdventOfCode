//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation

private struct Position {
    let x: Int
    let y: Int
}

private struct Button {
    let x: Int
    let y: Int
    let cost: Int
}

private struct ClawMachine {
    let buttonA: Button
    let buttonB: Button
    let prize: Position


    var bruteForceCost: Int? {
        var results: [(Int, Int)] = []
        (0...(100)).forEach { i in
            (0...(100)).forEach { j in
                if i * buttonA.x + j * buttonB.x == prize.x && i * buttonA.y + j * buttonB.y == prize.y {
                    results.append((i, j))
                }
            }
        }
        results.sort { left, right in
            (3 * left.0 + left.1) < (3 * right.0 + right.1)
        }
        guard let optimal = results.first else { return nil }
        return 3 * optimal.0 + optimal.1
    }


    var optimalCost: Int? {
        guard optimalCostOvershootA != nil || optimalCostOverShootB != nil else {
            return nil
        }
        return min(optimalCostOvershootA ?? Int.max, optimalCostOverShootB ?? Int.max)
    }

    var optimalCostOverShootB: Int? {
        let overshoot = max((prize.x / buttonB.x), (prize.y / buttonB.y)) + 1
        var pressA = 0
        var pressB = overshoot
        var targetX = pressA * buttonA.x + pressB * buttonB.x
        var targetY = pressA * buttonA.y + pressB * buttonB.y
        var results: [(Int, Int)] = []
        while pressA <= 100 {
            if targetX == prize.x && targetY == prize.y {
                results.append((pressA, pressB))
            }
            pressB -= 1
            targetX = pressA * buttonA.x + pressB * buttonB.x
            targetY = pressA * buttonA.y + pressB * buttonB.y
            while targetX < prize.x && targetY < prize.y {
                pressA += 1
                targetX = pressA * buttonA.x + pressB * buttonB.x
                targetY = pressA * buttonA.y + pressB * buttonB.y
            }
            if targetX > prize.x && targetY > prize.y {
                pressA -= 1
                targetX = pressA * buttonA.x + pressB * buttonB.x
                targetY = pressA * buttonA.y + pressB * buttonB.y
            }
        }
        results.sort { left, right in
            (3 * left.0 + left.1) < (3 * right.0 + right.1)
        }
        guard let optimal = results.first else { return nil }
        return 3 * optimal.0 + optimal.1
    }

    var optimalCostOvershootA: Int? {
        let overshoot = max((prize.x / buttonB.x), (prize.y / buttonB.y)) + 1
        var pressA = overshoot
        var pressB = 0
        var targetX = pressA * buttonA.x + pressB * buttonB.x
        var targetY = pressA * buttonA.y + pressB * buttonB.y
        var results: [(Int, Int)] = []
        while pressB <= 100 {
            if targetX == prize.x && targetY == prize.y {
                results.append((pressA, pressB))
            }
            pressA -= 1
            targetX = pressA * buttonA.x + pressB * buttonB.x
            targetY = pressA * buttonA.y + pressB * buttonB.y
            while targetX < prize.x && targetY < prize.y {
                pressB += 1
                targetX = pressA * buttonA.x + pressB * buttonB.x
                targetY = pressA * buttonA.y + pressB * buttonB.y
            }
            if targetX > prize.x && targetY > prize.y {
                pressB -= 1
                targetX = pressA * buttonA.x + pressB * buttonB.x
                targetY = pressA * buttonA.y + pressB * buttonB.y
            }
        }
        results.sort { left, right in
            (3 * left.0 + left.1) < (3 * right.0 + right.1)
        }
        guard let optimal = results.first else { return nil }
        return 3 * optimal.0 + optimal.1
    }
}


private func parseLines(_ lines: [String]) throws -> ClawMachine {
    var right = lines[0].components(separatedBy: ":")[1]
    let buttonPattern = #"X\+(\d+), Y\+(\d+)"#
    let buttonA = try parseRegexp(right, capturePattern: buttonPattern) { groups in
        return Button(x: Int(groups[1])!, y: Int(groups[2])!, cost: 3)
    }
    right = lines[1].components(separatedBy: ":")[1]
    let buttonB = try parseRegexp(right, capturePattern: buttonPattern) { groups in
        return Button(x: Int(groups[1])!, y: Int(groups[2])!, cost: 1)
    }
    right = lines[2].components(separatedBy: ":")[1]
    let prize = try parseRegexp(right, capturePattern: #"X=(\d+), Y=(\d+)"#) { groups in
        return Position(x: Int(groups[1])!, y: Int(groups[2])!)
    }
    return ClawMachine(buttonA: buttonA, buttonB: buttonB, prize: prize)
}

func day13_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day13_2024_input").getGroupedLines()
    let claws = try lines.map { group in
        return try parseLines(group)
    }
    let costs = claws.enumerated().compactMap { element in
        let (index, claw) = element
//        let brute = claw.bruteForceCost
        let optimal = claw.optimalCost
//        if (brute != optimal) {
//            print("-----")
//            print(claw)
//            print("brute: \(brute)")
//            print("optimal: \(optimal)")
//        }
        return optimal
    }
    return costs.reduce(0, +)
}

// MARK: - Part B

private func parseLinesSecondPart(_ lines: [String]) throws -> ClawMachine {
    var right = lines[0].components(separatedBy: ":")[1]
    let buttonPattern = #"X\+(\d+), Y\+(\d+)"#
    let buttonA = try parseRegexp(right, capturePattern: buttonPattern) { groups in
        return Button(x: Int(groups[1])!, y: Int(groups[2])!, cost: 3)
    }
    right = lines[1].components(separatedBy: ":")[1]
    let buttonB = try parseRegexp(right, capturePattern: buttonPattern) { groups in
        return Button(x: Int(groups[1])!, y: Int(groups[2])!, cost: 1)
    }
    right = lines[2].components(separatedBy: ":")[1]
    let prize = try parseRegexp(right, capturePattern: #"X=(\d+), Y=(\d+)"#) { groups in
        return Position(x: Int(groups[1])! + 10000000000000, y: Int(groups[2])! + 10000000000000)
    }
    return ClawMachine(buttonA: buttonA, buttonB: buttonB, prize: prize)
}

extension ClawMachine {
    var optimalCramerRule: Int? {
        let det = buttonA.x * buttonB.y - buttonB.x * buttonA.y
        guard det != 0 else { return nil }
        let pressA = (prize.x * buttonB.y - buttonB.x * prize.y) / det
        let pressB = (buttonA.x * prize.y - prize.x * buttonA.y) / det
        if pressA * buttonA.x + pressB * buttonB.x == prize.x,
           pressA * buttonA.y + pressB * buttonB.y == prize.y {
            return 3 * pressA + pressB
        }
        return nil
    }
}


func day13_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day13_2024_input").getGroupedLines()
    let claws = try lines.map { group in
//        return try parseLinesSecondPart(group)
        return try parseLinesSecondPart(group)
    }
    let costs = claws.compactMap { $0.optimalCramerRule }
    print(costs)
    return costs.reduce(0, +)
}
