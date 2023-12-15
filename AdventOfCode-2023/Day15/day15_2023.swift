//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private func hash(label: String) -> Int {
    var value = 0
    label.forEach { character in
        value = ((value + Int(character.asciiValue!)) * 17) % 256
    }
//    print("label: \(label), value: \(value)")
    return value
}

private func process(_ line: String) throws -> [Int] {
    return line.components(separatedBy: ",").map(hash(label:))
}

func day15_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day15_2023_input").getLines()
    return try process(lines[0]).reduce(0, +)
}

// MARK: - Part 2

private func processSecondPart(_ line: String) throws {
    let commands = line.components(separatedBy: ",")
    commands.forEach { command in
        if command.hasSuffix("-") {
            let label = command.dropLast(1)
            let boxNumber = hash(label: String(label))
            var array = hashmap[boxNumber] ?? []
            array.removeAll { $0.label == label }
            hashmap[boxNumber] = array
        } else {
            let components = command.components(separatedBy: "=")
            let label = components[0]
            let focal = Int(components[1])!
            let boxNumber = hash(label: label)
            var array = hashmap[boxNumber] ?? []
            if let foundLens = array.first(where: { $0.label == label }) {
                foundLens.focalLength = focal
            } else {
                array.append(Lens(label: command))
                hashmap[boxNumber] = array
            }
        }
    }
}

private class Lens {
    let label: String
    var focalLength: Int

    init(label: String) {
        let components = label.components(separatedBy: "=")
        self.label = components[0]
        self.focalLength = Int(components[1])!
    }
}

private var hashmap: [Int: [Lens]] = [:]

func day15_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day15_2023_input").getLines()
    try processSecondPart(lines[0])
    return hashmap.keys.sorted().flatMap { key -> [Int] in
        let box = hashmap[key] ?? []
        return box.enumerated().map { (index, lens) in
            (key + 1) * (index + 1) * lens.focalLength
        }
    }.reduce(0, +)
}
