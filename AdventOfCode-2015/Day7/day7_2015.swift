//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private enum Origin {
    case state(String)
    case raw(UInt16)
}

private enum Operation {
    case set(Origin)
    case and(Origin, Origin)
    case or(Origin, Origin)
    case lshift(Origin, Int)
    case rshift(Origin, Int)
    case not(Origin)
}

private struct Instruction {
    let operation: Operation
    let destination: String
}

private func parseOrigin(_ string: String) -> Origin {
    let trimmed = string.trimmingCharacters(in: .whitespaces)
    if let int = UInt16(trimmed) {
        return .raw(int)
    }
    return .state(trimmed)
}

private func parse(_ string: String) throws -> Instruction {
    let components = string.components(separatedBy: "->")
    let destination = components[1]
    if !components[0].contains(try Regex(#"(AND|OR|LSHIFT|RSHIFT|NOT)"#)) {
        let operation = Operation.set(parseOrigin(components[0]))
        return Instruction(operation: operation, destination: destination.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    return try parseRegexp(
        components[0],
        capturePattern: #"(\w+) (AND|OR|LSHIFT|RSHIFT) (\w+)|(NOT) (\w+)"#) { groups in
            let operation: Operation
            switch groups.count {
            case 3:
                operation = Operation.not(parseOrigin(groups[2]))
            case 4:
                switch groups[2] {
                case "AND":
                    operation = Operation.and(parseOrigin(groups[1]), parseOrigin(groups[3]))
                case "OR":
                    operation = Operation.or(parseOrigin(groups[1]), parseOrigin(groups[3]))
                case "LSHIFT":
                    operation = Operation.lshift(parseOrigin(groups[1]), Int(groups[3])!)
                case "RSHIFT":
                    operation = Operation.rshift(parseOrigin(groups[1]), Int(groups[3])!)
                default:
                    throw AoCError.wrongFormat
                }
            default:
                throw AoCError.wrongFormat
            }
            return Instruction(operation: operation, destination: destination.trimmingCharacters(in: .whitespacesAndNewlines))
        }
}

private var states: [String: UInt16] = [:]

private func value(_ origin: Origin) -> UInt16? {
    switch origin {
    case .state(let string):
        if string == "b" && overrideB {
            return overridenValue
        }
        return states[string]
    case .raw(let uInt16):
        return uInt16
    }
}

func day7_2015_A() throws -> Int {
    let lines = try FileReader(filename: "day7_2015_input").getLines()
    let instructions = try lines.map(parse(_:))
    var queue = instructions
    while !queue.isEmpty {
        let instruction = queue.removeFirst()
        switch instruction.operation {
        case .set(let origin):
            if let value = value(origin) {
                states[instruction.destination] = value
            } else {
                queue.append(instruction)
            }
        case let .and(left, right):
            if let leftValue = value(left),
               let rightValue = value(right) {
                states[instruction.destination] = leftValue & rightValue
            } else {
                queue.append(instruction)
            }
        case let .or(left, right):
            if let leftValue = value(left),
               let rightValue = value(right) {
                states[instruction.destination] = leftValue | rightValue
            } else {
                queue.append(instruction)
            }
        case let .lshift(origin, shift):
            if let value = value(origin) {
                states[instruction.destination] = value << shift
            } else {
                queue.append(instruction)
            }
        case let .rshift(origin, shift):
            if let value = value(origin) {
                states[instruction.destination] = value >> shift
            } else {
                queue.append(instruction)
            }
        case let .not(origin):
            if let value = value(origin) {
                states[instruction.destination] = ~value
            } else {
                queue.append(instruction)
            }
        }
    }
    return Int(states["a"] ?? 0)
}

// MARK: - Part 2

private var overrideB = false
private var overridenValue: UInt16?

func day7_2015_B() throws -> Int {
    _ = try day7_2015_A()
    overridenValue = states["a"]
    states.removeAll()
    overrideB = true
    return try day7_2015_A()
}
