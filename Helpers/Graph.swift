//
//  Graph.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 10/06/2022.
//

import Foundation

// https://www.raywenderlich.com/773-swift-algorithm-club-graphs-with-adjacency-list

struct Vertex<T: Hashable> {
    var data: T
}

extension Vertex: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }

    static public func ==(lhs: Vertex, rhs: Vertex) -> Bool { // 2
        return lhs.data == rhs.data
    }
}

extension Vertex: CustomStringConvertible {
    public var description: String {
        return "\(data)"
    }
}

enum EdgeType {
    case directed, undirected
}

struct Edge<T: Hashable> {
    var source: Vertex<T> // 1
    var destination: Vertex<T>
    let weight: Double? // 2
}

extension Edge: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(source)
        hasher.combine(destination)
        hasher.combine(weight)
    }

    static public func ==(lhs: Edge<T>, rhs: Edge<T>) -> Bool {
        return lhs.source == rhs.source &&
        lhs.destination == rhs.destination &&
        lhs.weight == rhs.weight
    }
}

protocol Graphable {
    associatedtype Element: Hashable // 1
    var description: CustomStringConvertible { get } // 2

    func createVertex(data: Element) -> Vertex<Element> // 3
    func add(_ type: EdgeType, from source: Vertex<Element>, to destination: Vertex<Element>, weight: Double?) // 4
    func weight(from source: Vertex<Element>, to destination: Vertex<Element>) -> Double? // 5
    func edges(from source: Vertex<Element>) -> [Edge<Element>]? // 6
}

open class AdjacencyList<T: Hashable> {
    var adjacencyDict : [Vertex<T>: [Edge<T>]] = [:]
    init() {}

    fileprivate func addDirectedEdge(from source: Vertex<Element>, to destination: Vertex<Element>, weight: Double?) {
        let edge = Edge(source: source, destination: destination, weight: weight) // 1
        adjacencyDict[source]?.append(edge) // 2
    }

    fileprivate func addUndirectedEdge(vertices: (Vertex<Element>, Vertex<Element>), weight: Double?) {
        let (source, destination) = vertices
        addDirectedEdge(from: source, to: destination, weight: weight)
        addDirectedEdge(from: destination, to: source, weight: weight)
    }


}

extension AdjacencyList: Graphable {
    typealias Element = T

    func createVertex(data: Element) -> Vertex<Element> {
        let vertex = Vertex(data: data)

        if adjacencyDict[vertex] == nil {
            adjacencyDict[vertex] = []
        }

        return vertex
    }

    func add(_ type: EdgeType, from source: Vertex<Element>, to destination: Vertex<Element>, weight: Double?) {
        switch type {
        case .directed:
            addDirectedEdge(from: source, to: destination, weight: weight)
        case .undirected:
            addUndirectedEdge(vertices: (source, destination), weight: weight)
        }
    }

    func weight(from source: Vertex<Element>, to destination: Vertex<Element>) -> Double? {
        guard let edges = adjacencyDict[source] else { // 1
            return nil
        }

        for edge in edges { // 2
            if edge.destination == destination { // 3
                return edge.weight
            }
        }

        return nil // 4
    }

    func edges(from source: Vertex<Element>) -> [Edge<Element>]? {
        return adjacencyDict[source]
    }

    var description: CustomStringConvertible {
        var result = ""
        for (vertex, edges) in adjacencyDict {
            var edgeString = ""
            for (index, edge) in edges.enumerated() {
                if index != edges.count - 1 {
                    edgeString.append("\(edge.destination), ")
                } else {
                    edgeString.append("\(edge.destination)")
                }
            }
            result.append("\(vertex) ---> [ \(edgeString) ] \n ")
        }
        return result
    }

}
