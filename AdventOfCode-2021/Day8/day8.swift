//
//  day8.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 09/06/2022.
//

import Foundation

fileprivate struct Input {
    let patterns: [String]
    let output: [String]

    init(string: String) throws {
        let comps = string.components(separatedBy: " | ")
        guard comps.count == 2 else {
            throw AoCError.wrongFormat
        }
        patterns = comps[0].components(separatedBy: .whitespaces)
        output = comps[1].components(separatedBy: .whitespaces)
    }
}

func day8_A() throws -> Int {
    let lines = try FileReader(filename: "day8_input").getLines()
    let inputs = try lines.map { try Input(string: $0) }
    let answer = inputs.reduce(into: 0) { partialResult, input in
        let rowValue = input.output.reduce(into: 0) { partialResult, digit in
            switch digit.count {
            case 2, 3, 4, 7:
                partialResult += 1
            default:
                break
            }
        }
        partialResult += rowValue
    }
    return answer
}

fileprivate struct SetInput {
    let patterns: [Set<Character>]
    let output: [Set<Character>]

    init(string: String) throws {
        let comps = string.components(separatedBy: " | ")
        guard comps.count == 2 else {
            throw AoCError.wrongFormat
        }
        patterns = comps[0].components(separatedBy: .whitespaces).map({ string in
            let chars = string.enumerated().map { element -> Character in
                return element.element as Character
            }
            return Set(chars)
        })
        output = comps[1].components(separatedBy: .whitespaces).map({ string in
            let chars = string.enumerated().map { element -> Character in
                return element.element as Character
            }
            return Set(chars)
        })
    }

    func solvedOutput() throws -> Int {
        var display = Display()
        let one = patterns.first { $0.count == 2 }!
        let four = patterns.first { $0.count == 4 }!
        let seven = patterns.first { $0.count == 3 }!
        let eight = patterns.first { $0.count == 7 }!
        display.top = seven.subtracting(one).first!
        // digit 0, 6 and 9
        let sixSegmentSets = patterns.filter { $0.count == 6 }
        // digit 2, 3 and 5
        let fiveSegmentSets = patterns.filter { $0.count == 5 }
        let nine = sixSegmentSets.first { $0.intersection(four) == four }!
        display.bottomLeft = eight.subtracting(nine).first!
        let zero = sixSegmentSets.first { $0 != nine && $0.intersection(seven) == seven }!
        display.middle = eight.subtracting(zero).first!
        let six = sixSegmentSets.first { $0 != nine && $0 != zero }!
        display.topRight = eight.subtracting(six).first!
        let twoChecker = Set([display.top!, display.bottomLeft!, display.middle!, display.topRight!])
        let two = fiveSegmentSets.first { $0.subtracting(twoChecker).count == 1 }!
        display.bottom = two.subtracting(twoChecker).first!
        display.bottomRight = one.subtracting(Set([display.topRight!])).first!
        let three = Set([display.top!, display.bottom!, display.middle!, display.topRight!, display.bottomRight!])
        let topLeftComplementary = Set([
            display.top!,
            display.topRight!,
            display.middle!,
            display.bottomLeft!,
            display.bottomRight!,
            display.bottom!
        ])
        display.topLeft = eight.subtracting(topLeftComplementary).first!
        let five = Set([
            display.top!,
            display.topLeft!,
            display.middle!,
            display.bottomRight!,
            display.bottom!
        ])
        let mappedSets = [zero: 0, one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8, nine: 9]
        return try output.enumerated().reduce(into: 0, { partialResult, element in
            let (index, set) = element
            guard let value = mappedSets[set] else {
                throw AoCError.resultNotFound
            }
            partialResult += value * Int(pow(Double(10), Double(3 - index)))
        })
    }
}

fileprivate struct Display {
    var top: Character?
    var topLeft: Character?
    var topRight: Character?
    var middle: Character?
    var bottomLeft: Character?
    var bottomRight: Character?
    var bottom: Character?

    var description: String {
        return
            " \(top!)\(top!)\(top!)\(top!) \n" +
            "\(topLeft!)  \(topRight!)\n" +
            "\(topLeft!)  \(topRight!)\n" +
            " \(middle!)\(middle!)\(middle!)\(middle!) \n" +
            "\(bottomLeft!)  \(bottomRight!)\n" +
            "\(bottomLeft!)  \(bottomRight!)\n" +
            " \(bottom!)\(bottom!)\(bottom!)\(bottom!) \n"
    }
}

func day8_B() throws -> Int {
    let lines = try FileReader(filename: "day8_input").getLines()
    let inputs = try lines.map { try SetInput(string: $0) }
    let answer = try inputs.reduce(into: 0) { partialResult, input in
        partialResult += try input.solvedOutput()
    }
    return answer
}
