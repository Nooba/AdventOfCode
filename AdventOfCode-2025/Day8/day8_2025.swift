//
//  day1_2025.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2025.
//

import Foundation
import Algorithms

private struct JunctionBox: Hashable, CustomDebugStringConvertible {
    let x: Int
    let y: Int
    let z: Int

    init(string: String) {
        let components = string.components(separatedBy: ",").map { Int($0) }
        self.x = components[0]!
        self.y = components[1]!
        self.z = components[2]!
    }

    func distance(to: JunctionBox) -> Int {
        let deltaX = x - to.x
        let deltaY = y - to.y
        let deltaZ = z - to.z
        return deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ
    }

    var debugDescription: String {
        return "\(x),\(y),\(z)"
    }
}

private struct Tuple: Hashable, CustomDebugStringConvertible {
    let left: JunctionBox
    let right: JunctionBox

    var debugDescription: String {
        return "\(left.debugDescription)|\(right.debugDescription)|\(left.distance(to: right))"
    }

}

private var distances = [Int: Tuple]()

func day8_2025_A() throws -> Int {
//    let iterations = 10 // example
//    let lines = try FileReader(filename: "day8_2025_example").getLines()
    let iterations = 1000 // input
    let lines = try FileReader(filename: "day8_2025_input").getLines()
    let boxes = lines.map { JunctionBox(string: $0) }
    for i in 0..<boxes.count {
        for j in i+1..<boxes.count {
            let left = boxes[i]
            let right = boxes[j]
            let tuple = Tuple(left: left, right: right)
            let distance = left.distance(to: right)
            // assume no distance equality
            distances[distance] = tuple
        }
    }
    let sortedDistances = distances.keys.sorted()
    var circuits = [JunctionBox: Int]()
    var nextId = 1
    for i in 0..<iterations {
        let nextDistance = sortedDistances[i]
        let tuple = distances[nextDistance]!
//        print(tuple)
        let leftCircuit = circuits[tuple.left]
        let rightCircuit = circuits[tuple.right]
        switch (leftCircuit, rightCircuit) {
        case let (.some(leftId), .some(rightId)):
            guard leftId != rightId else { continue }
            circuits.keys.forEach { key in
                if circuits[key] == rightId {
                    circuits[key] = leftId
                }
            }
        case let (.some(leftId), .none):
            circuits[tuple.right] = leftId
        case let (.none, .some(rightId)):
            circuits[tuple.left] = rightId
        case (.none, .none):
            circuits[tuple.left] = nextId
            circuits[tuple.right] = nextId
            nextId += 1
        }
    }
    print(circuits)
    let circuitSizes = circuits.reduce(into: [Int: Int]()) { (partialResult, element) in
        let (_, value) = element
        partialResult[value] = (partialResult[value] ?? 0) + 1
    }
    print(circuitSizes)
    return circuitSizes.values.sorted().reversed().prefix(3).reduce(1, *)
}

// MARK: - Part B

func day8_2025_B() throws -> Int {
//    let a = JunctionBox(string: "117,168,530")
//    let b = JunctionBox(string: "216,146,977")
//    print(a.distance(to: b))
    let lines = try FileReader(filename: "day8_2025_input").getLines()
    let boxes = lines.map { JunctionBox(string: $0) }
    for i in 0..<boxes.count {
        for j in i+1..<boxes.count {
            let left = boxes[i]
            let right = boxes[j]
            let tuple = Tuple(left: left, right: right)
            let distance = left.distance(to: right)
            // assume no distance equality
            distances[distance] = tuple
        }
    }
    let sortedDistances = distances.keys.sorted()
    var circuits = [JunctionBox: Int]()
    var nextId = 1
    var i = -1
    var triggerTuple: Tuple?
    while triggerTuple == nil {
        i += 1
        let nextDistance = sortedDistances[i]
//        if nextDistance == 210094 {
//            print("SHOULD END HERE")
//        }
        let tuple = distances[nextDistance]!
//        print(tuple)
        let leftCircuit = circuits[tuple.left]
        let rightCircuit = circuits[tuple.right]
        switch (leftCircuit, rightCircuit) {
        case let (.some(leftId), .some(rightId)):
            guard leftId != rightId else { continue }
            circuits.keys.forEach { key in
                if circuits[key] == rightId {
                    circuits[key] = leftId
                }
            }
            if circuits.keys.count == boxes.count,
               (circuits.values.allSatisfy { $0 == leftId }) {
                triggerTuple = tuple
            }
        case let (.some(leftId), .none):
            circuits[tuple.right] = leftId
            if circuits.keys.count == boxes.count,
               (circuits.values.allSatisfy { $0 == leftId }) {
                triggerTuple = tuple
            }
        case let (.none, .some(rightId)):
            circuits[tuple.left] = rightId
            if circuits.keys.count == boxes.count,
               (circuits.values.allSatisfy { $0 == rightId }) {
                triggerTuple = tuple
            }
        case (.none, .none):
            circuits[tuple.left] = nextId
            circuits[tuple.right] = nextId
            nextId += 1
        }
    }
    print(triggerTuple)
    return triggerTuple!.left.x * triggerTuple!.right.x
}
