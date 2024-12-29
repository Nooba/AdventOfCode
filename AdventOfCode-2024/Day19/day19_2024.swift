//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation

private enum Stripes: String, CustomStringConvertible {
    case white = "w"
    case blue = "u"
    case black = "b"
    case red = "r"
    case green = "g"

    var description: String {
        return rawValue.capitalized
    }

}

private typealias Pattern = [Stripes]

private class Solver: CustomStringConvertible {
    let target: Pattern
    var testing: [Pattern]
    var tested: [Pattern: [Pattern]]
    var testedSecondPart: [[Pattern]: [Pattern]] = [:]
    var solutions = Set<[Pattern]>()

    init(target: Pattern, testing: [Pattern], tested: [Pattern : [Pattern]]) {
        self.target = target
        self.testing = testing
        self.tested = tested
    }

    enum Status {
        case solved
        case impossible
        case toContinue
    }

    var status: Status {
        let testTarget = testing.flatMap { $0 }
        if testTarget == target {
            return .solved
        } else if testTarget.count >= target.count {
            return .impossible
        }
        return .toContinue
    }

    var description: String {
        return "target: \(target.compactMap({ $0.description }).joined()), current: \(testing.compactMap({ $0.description }).joined())"
    }
}

private var availablePatterns = Set<Pattern>()
private var impossiblePatterns = Set<Pattern>()
private var possiblePatterns = Set<Pattern>()

private func parsePatterns(_ line: String) {
    let components = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    let stripes = components.map { $0.map { Stripes(rawValue: String($0))! } }
    availablePatterns = Set(stripes)
}

private func parseDesigns(_ line: String) -> Solver {
    let stripes = line.map { Stripes(rawValue: String($0))! }
    return Solver(target: stripes, testing: [], tested: [:])
}

private func generateAllPossiblePatterns(from: Pattern, maxLength: Int) {
    let usables = availablePatterns.filter { $0.count + from.count <= maxLength }
    usables.forEach { addition in
        let new = from + addition
        possiblePatterns.insert(new)
        generateAllPossiblePatterns(from: new, maxLength: maxLength)
    }
}

private func isDesign(_ design: Pattern, validFrom patterns: Set<Pattern>) -> Bool {
    guard !patterns.contains(design) else { return true }
    var step = 1
    var hasFound = false
    while step < design.count {
        let usablePatterns = patterns.filter { pattern in
            return pattern[0..<step] == design[0..<step]
        }
        print("usables for \(design): \(usablePatterns)")
        let found = usablePatterns.first { pattern in
            isDesign(Array(design[step..<design.count]), validFrom: patterns)
        }
        if found == nil {
            step += 1
        } else {
            hasFound = true
        }
        print(found)
    }
    return hasFound
}

private extension Solver {

    private var currentPart: Pattern {
        testing.flatMap { $0 }
    }

    private var nextPart: Pattern {
        Array(target[testing.flatMap { $0 }.count..<target.count])
    }

    func solve(from availablePatterns: Set<Pattern>) -> Bool {
        var solvable = true
        while status != .solved, solvable {
            print(self)
            let newMaxLength = nextPart.count
            let validPatterns = availablePatterns.filter { pattern in
                guard pattern.count <= newMaxLength else { return false }
                let alreadyTried = tested[currentPart]?.first(where: { $0 == pattern })
                guard alreadyTried == nil else { return false }
                return Array(nextPart[0..<pattern.count]) == pattern
            }.sorted { left, right in
                left.count > right.count
            }
            if validPatterns.isEmpty {
                if testing.isEmpty {
                    solvable = false
                    break
                }
                _ = testing.popLast()
            } else {
                let next = validPatterns.first!
                var array = tested[currentPart] ?? []
                array.append(next)
                tested[currentPart] = array
                testing.append(next)
            }
        }
        return solvable
    }
}

func day19_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day19_2024_input").getGroupedLines()
    parsePatterns(lines[0].first!)
    let solvers = lines[1].map { parseDesigns($0) }
//    print(availablePatterns)
//    generateAllPossiblePatterns(from: [], maxLength: maximumDesignLength)
//    return designs.filter { design in
//        possiblePatterns.contains(design)
//    }.count
    return solvers.map { solve in
        print("\n\ntesting: \(solve)")
        return solve.solve(from: availablePatterns)
    }.filter { $0 }.count

    // 400 too high
    // 269 *
}

private extension Solver {

    func reinit() {
        tested = [:]
        testing = []
    }

    func solveSecondPart(from availablePatterns: Set<Pattern>) -> Int {
        reinit()
        while (tested[[]] ?? []).count < availablePatterns.count {
//            print(self)
            let newMaxLength = nextPart.count
            let validPatterns = availablePatterns.filter { pattern in
                guard pattern.count <= newMaxLength else { return false }
                let alreadyTried = testedSecondPart[testing]?.first(where: { $0 == pattern })
                guard alreadyTried == nil else { return false }
                return Array(nextPart[0..<pattern.count]) == pattern
            }.sorted { left, right in
                left.count > right.count
            }
            if validPatterns.isEmpty {
                if testing.isEmpty {
                    break
                }
                _ = testing.popLast()
            } else {
                let next = validPatterns.first!
                var array = testedSecondPart[testing] ?? []
                array.append(next)
                testedSecondPart[testing] = array
                testing.append(next)
                if status == .solved {
                    solutions.insert(testing)
                }
            }
        }
        return solutions.count
    }
}

// MARK: - Part B

func day19_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day19_2024_input").getGroupedLines()
    parsePatterns(lines[0].first!)
    let solvers = lines[1].map { parseDesigns($0) }
    let mapped = solvers.filter { solve in
        return solve.solve(from: availablePatterns)
    }.enumerated().map { (index, solve) in
        print(index)
        return solve.solveSecondPart(from: availablePatterns)
    }
    print(mapped)
    return mapped.reduce(0, +)
}
