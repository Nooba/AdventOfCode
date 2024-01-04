//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

private enum Directions: String {
    case up = "^"
    case left = "<"
    case right = ">"
    case down = "v"
}

private struct Position: Hashable {
    let x: Int
    let y: Int
}

func day3_2015_A() throws -> Int {
    let lines = try FileReader(filename: "day3_2015_input").getLines()
    let instructions = lines[0].compactMap { Directions(rawValue: String($0)) }
    var visitedSet = Set<Position>()
    var position = Position(x: 0, y: 0)
    visitedSet.insert(position)
    instructions.forEach { direction in
        switch direction {
        case .up:
            position = Position(x: position.x, y: position.y + 1)
        case .left:
            position = Position(x: position.x - 1, y: position.y)
        case .right:
            position = Position(x: position.x + 1, y: position.y)
        case .down:
            position = Position(x: position.x, y: position.y - 1)
        }
        visitedSet.insert(position)
    }
    return visitedSet.count
}

func day3_2015_B() throws -> Int {
    let lines = try FileReader(filename: "day3_2015_input").getLines()
    let instructions = lines[0].compactMap { Directions(rawValue: String($0)) }
    var visitedSet = Set<Position>()
    var santaPosition = Position(x: 0, y: 0)
    var robotPosition = Position(x: 0, y: 0)
    visitedSet.insert(santaPosition)
    instructions.enumerated().forEach { element in
        let (index, direction) = element
        switch direction {
        case .up:
            if index.isMultiple(of: 2) {
                robotPosition = Position(x: robotPosition.x, y: robotPosition.y + 1)
            } else {
                santaPosition = Position(x: santaPosition.x, y: santaPosition.y + 1)
            }
        case .left:
            if index.isMultiple(of: 2) {
                robotPosition = Position(x: robotPosition.x - 1, y: robotPosition.y)
            } else {
                santaPosition = Position(x: santaPosition.x - 1, y: santaPosition.y)
            }
        case .right:
            if index.isMultiple(of: 2) {
                robotPosition = Position(x: robotPosition.x + 1, y: robotPosition.y)
            } else {
                santaPosition = Position(x: santaPosition.x + 1, y: santaPosition.y)
            }
        case .down:
            if index.isMultiple(of: 2) {
                robotPosition = Position(x: robotPosition.x, y: robotPosition.y - 1)
            } else {
                santaPosition = Position(x: santaPosition.x, y: santaPosition.y - 1)
            }
        }
        if index.isMultiple(of: 2) {
            visitedSet.insert(robotPosition)
        } else {
            visitedSet.insert(santaPosition)
        }
    }
    return visitedSet.count
}
