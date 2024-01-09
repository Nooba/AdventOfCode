//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation
import Algorithms

// MARK: - Part 1

private let graph = AdjacencyList<String>()

private func process(_ string: String) throws {
    try parseRegexp(string, capturePattern: #"(\w+) to (\w+) = (\d+)"#) { groups in
        let origin = graph.createVertex(data: groups[0])
        let destination = graph.createVertex(data: groups[1])
        graph.add(.undirected, from: origin, to: destination, weight: Double(groups[2])!)
    }
}

private func computeDistance(permutation: [String]) -> Int {
    return permutation.enumerated().reduce(into: 0) { partialResult, iterator in
        let (index, element) = iterator
        guard index > 0 else { return }
        let previous = permutation[index - 1]
        let next = element
        guard let weight = (graph.edges(from: Vertex(data: previous))?.first(where: { $0.destination.data == next })?.weight) else {
            return
        }
        return partialResult += Int(weight)
    }
}

private func computeAllDistances() throws -> [Int] {
    let lines = try FileReader(filename: "day9_2015_input").getLines()
    try lines.forEach(process(_:))
    let allCities = Array(graph.adjacencyDict.keys)
    let names = allCities.map { $0.data }
    let allPermutations = names.permutations()
    let distances = allPermutations.map { permutation in
        computeDistance(permutation: permutation)
    }
    return distances
}

func day9_2015_A() throws -> Int {
    return try computeAllDistances().min()!
}

// MARK: - Part 2

func day9_2015_B() throws -> Int {
    return try computeAllDistances().max()!
}
