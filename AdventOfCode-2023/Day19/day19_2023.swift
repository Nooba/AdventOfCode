//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private struct Part {
    let x: Int
    let m: Int
    let a: Int
    let s: Int

    // {x=787,m=2655,a=1222,s=2876}, always ordered like this in the input
    init(string: String) {
        let newString = string[
            string.index(string.startIndex, offsetBy: 1)..<string.index(string.endIndex, offsetBy: -1)
        ]
        let components = newString.components(separatedBy: ",")
        x = Int(components[0].components(separatedBy: "=").last!)!
        m = Int(components[1].components(separatedBy: "=").last!)!
        a = Int(components[2].components(separatedBy: "=").last!)!
        s = Int(components[3].components(separatedBy: "=").last!)!
    }

    var totalRating: Int {
        return x + m + a + s
    }
}

private struct Rule: CustomStringConvertible {
    enum ComparisonType: String {
        case gt = ">"
        case lt = "<"
    }

    enum RuleType {
        case comparison(KeyPath<Part, Int>, ComparisonType, Int, String)
        case goto(String)
        case accept
        case reject

        init(string: String) {
            switch string {
            case "A":
                self = .accept
            case "R":
                self = .reject
            default:
                self = .goto(string)
            }
        }
    }

    let type: RuleType

    init(string: String) {
        let components = string.components(separatedBy: ":")
        guard components.count == 2 else {
            type = RuleType(string: string)
            return
        }
        let destination = components[1]
        let isLt = components[0].firstRange(of: "<") != nil
        let comparisonCompoments = components[0].components(separatedBy: CharacterSet(arrayLiteral: "<", ">"))
        let keypath: KeyPath<Part, Int>
        switch comparisonCompoments[0] {
        case "x": keypath = \.x
        case "m": keypath = \.m
        case "a": keypath = \.a
        case "s": keypath = \.s
        default:
            fatalError("Unexpected value")
        }
        type = .comparison(keypath, isLt ? .lt : .gt, Int(comparisonCompoments[1])!, destination)
    }

    var description: String {
        switch self.type {
        case .comparison(let keyPath, let comparisonType, let int, let string):
            return "\(keyPath)\(comparisonType.rawValue)\(int):\(string)"
        case .goto(let string):
            return string
        case .accept:
            return "A"
        case .reject:
            return "R"
        }
    }

    var destination: String {
        switch self.type {
        case .comparison(_, _, _, let string):
            return string
        case .goto(let string):
            return string
        case .accept:
            return "A"
        case .reject:
            return "R"
        }
    }
}

private struct Workflow: CustomStringConvertible {
    let label: String
    let rules: [Rule]

    init(string: String) {
        let components = string.components(separatedBy: CharacterSet(arrayLiteral: "{", "}"))
        label = components[0]
        rules = components[1].components(separatedBy: ",").map { Rule(string: $0) }
    }

    var description: String {
        "\(label){\(rules.map { $0.description }.joined(separator: ","))}"
    }

    func process(part: Part) -> String {
        let foundRule = rules.first { rule in
            switch rule.type {
            case .comparison(let keyPath, let comparisonType, let int, _):
                let value = part[keyPath: keyPath]
                switch comparisonType {
                case .gt:
                    return value > int
                case .lt:
                    return value < int
                }
            case .goto, .accept, .reject:
                return true
            }
        }
        guard let foundRule else {
            fatalError("Workflow failed")
        }
        return foundRule.destination
    }
}

private func process(_ line: String) throws -> Int {
    return -1
}

func day19_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day19_2023_input").getGroupedLines()
    let workflows = lines[0].map { Workflow(string: $0) }
    var workflowHash = [String: Workflow]()
    var workflowQueues = [String: [Part]]()
    workflows.forEach { workflowHash[$0.label] = $0 }
    let parts = lines[1].map { Part(string: $0) }
    workflowQueues["in"] = parts
    var partsToProcess = parts.count
    while partsToProcess > 0 {
        workflowQueues.keys.forEach { key in
            guard key != "A", key != "R" else { return }
            let workflow = workflowHash[key]!
            let parts = workflowQueues[key] ?? []
            parts.forEach({ part in
                let destination = workflow.process(part: part)
                var queue = workflowQueues[destination] ?? []
                queue.append(part)
                workflowQueues[destination] = queue
            })
            workflowQueues[key] = []
        }
        partsToProcess = workflowQueues.reduce(into: 0, { partialResult, element in
            let (key, value) = element
            if key != "A" && key != "R" {
                partialResult += value.count
            }
        })
    }
    let acceptedParts = workflowQueues["A"] ?? []
    let ratings = acceptedParts.map { $0.totalRating }.reduce(0, +)
    return ratings
}

// MARK: - Part 2

private func processSecondPart(_ line: String) throws -> Int {
    return -1
}

func day19_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day19_2023_example").getLines()
    let results = try lines.map(processSecondPart(_:))
    return -1
}
