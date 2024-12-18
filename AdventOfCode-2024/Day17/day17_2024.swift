//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation

private class Computer: CustomDebugStringConvertible {
    var registerA: Int
    var registerB: Int
    var registerC: Int

    var program: [Int]
    var instructionPointer = 0
    var output: [Int] = []

    var halts = false

    init(registerA: Int, registerB: Int, registerC: Int, program: [Int]) {
        self.registerA = registerA
        self.registerB = registerB
        self.registerC = registerC
        self.program = program
    }

    var debugDescription: String {
        return """
RegisterA: \(registerA)
RegisterB: \(registerB)
RegisterC: \(registerC)
Program: \(program)
"""
    }

    func processOneInstruction() {
        guard !halts else { return }
        guard let function = program[safe: instructionPointer],
              let instruction = program[safe: instructionPointer + 1] else {
            halts = true
            return
        }
        functions[function]!(instruction)
    }

    // MARK: - Private

    private var functions: [Int: ((Int) -> Void)] {
        return [
            0: adv(instruction:),
            1: bxl(instruction:),
            2: bst(instruction:),
            3: jnz(instruction:),
            4: bxc(instruction:),
            5: out(instruction:),
            6: bdv(instruction:),
            7: cdv(instruction:),
        ]
    }

    private func convertToCombo(operand: Int) -> Int {
        switch operand {
        case 0, 1, 2, 3:
            return operand
        case 4:
            return registerA
        case 5:
            return registerB
        case 6:
            return registerC
        case 7:
            assertionFailure("Unexpected value")
        default:
            assertionFailure("Unexpected value")
        }
        return -1
    }

    private func adv(instruction: Int) {
        registerA = somedv(instruction: instruction)
        instructionPointer += 2
    }

    private func bxl(instruction: Int) {
        registerB = instruction ^ registerB
        instructionPointer += 2
    }

    private func bst(instruction: Int) {
        registerB = convertToCombo(operand: instruction) % 8
        instructionPointer += 2
    }

    private func jnz(instruction: Int) {
        guard registerA != 0 else {
            instructionPointer += 2
            return
        }
        instructionPointer = instruction
    }

    private func bxc(instruction: Int) {
        registerB = registerB ^ registerC
        instructionPointer += 2
    }

    private func out(instruction: Int) {
        output.append(convertToCombo(operand: instruction) % 8)
        instructionPointer += 2
    }

    private func bdv(instruction: Int) {
        registerB = somedv(instruction: instruction)
        instructionPointer += 2
    }

    private func cdv(instruction: Int) {
        registerC = somedv(instruction: instruction)
        instructionPointer += 2
    }

    private func somedv(instruction: Int) -> Int {
        let result = Double(registerA) / powl(2, Double(convertToCombo(operand: instruction)))
        return Int(result)
    }
}

private func parseComputer(_ lines: [String]) throws -> Computer {
    let a = try parseRegexp(lines[0], capturePattern: #"Register A: (\d+)"#) { groups in
        return Int(groups[0])!
    }
    let b = try parseRegexp(lines[1], capturePattern: #"Register B: (\d+)"#) { groups in
        return Int(groups[0])!
    }
    let c = try parseRegexp(lines[2], capturePattern: #"Register C: (\d+)"#) { groups in
        return Int(groups[0])!
    }
    let program = String(lines[3].dropping(prefix: "Program: ")).components(separatedBy: ",").map { Int($0)! }
    return Computer(registerA: a, registerB: b, registerC: c, program: program)
}

func day17_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day17_2024_input").getLines()
    let computer = try parseComputer(lines)
    print(computer)
    while !computer.halts {
        computer.processOneInstruction()
    }
    print(computer.output.map { String($0) }.joined(separator: ","))
    return -1
}

// MARK: - Part B

func day17_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day17_2024_input").getLines()
    return -1
}
