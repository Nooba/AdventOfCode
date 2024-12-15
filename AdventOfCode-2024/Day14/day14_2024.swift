//
//  day1_2024.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/12/2024.
//

import Foundation

private struct Position: CustomStringConvertible {
    let x: Int
    let y: Int

    var description: String {
        return "\(x), \(y)"
    }
}

private class Robot: CustomStringConvertible {
    var position: Position
    var velocity: Position

    init(position: Position, velocity: Position) {
        self.position = position
        self.velocity = velocity
    }

    var description: String {
        return "Robot at (\(position.description))"
    }
}

private class Cell {
    var robots: [Robot]

    init(robots: [Robot]) {
        self.robots = robots
    }
}

private struct Map {
    let rows: [[Cell]]

    init(rows: [[Cell]]) {
        self.rows = rows
    }

    var maxX: Int {
        rows.map { $0.count }.max() ?? 0
    }

    var maxY: Int {
        return rows.count
    }

    subscript(x: Int, y: Int) -> Cell? {
        return rows[safe: y]?[safe: x].map { $0 }
    }

    subscript(position: Position) -> Cell? {
        self[position.x, position.y]
    }
}

private func parseLine(_ line: String) throws -> Robot {
    return try parseRegexp(line, capturePattern: #"-?\d+"#, getAllMatches: true) { groups in
        let position = Position(x: Int(groups[0])!, y: Int(groups[1])!)
        let velocity = Position(x: Int(groups[2])!, y: Int(groups[3])!)
        return Robot(position: position, velocity: velocity)
    }
}

private func initializeMap(withRobots robots: [Robot]) -> Map {
    var rows: [[Cell]] = []
    (1...103).forEach { y in
        var row: [Cell] = []
        (1...101).forEach { x in
            row.append(Cell(robots: []))
        }
        rows.append(row)
    }
    let map = Map(rows: rows)

    robots.forEach { robot in
        map[robot.position]?.robots.append(robot)
    }
    return map
}


private func blink(robots: [Robot], maxX: Int, maxY: Int) -> [Robot] {
    return robots.map { robot in
        var newX = (robot.position.x + robot.velocity.x) % maxX
        var newY = (robot.position.y + robot.velocity.y) % maxY
        if newX < 0 { newX += maxX }
        if newY < 0 { newY += maxY }
        return Robot(position: Position(x: newX, y: newY), velocity: robot.velocity)
    }
}

private func safetyFactor(robots: [Robot], maxX: Int, maxY: Int) -> Int {
    var NE = 0
    var SE = 0
    var NW = 0
    var SW = 0

    let middleX = (maxX - 1) / 2
    let middleY = (maxY - 1) / 2

    robots.forEach { robot in

        if robot.position.x < middleX && robot.position.y < middleY {
            NW += 1
        } else if robot.position.x < middleX && robot.position.y > middleY {
            SW += 1
        } else if robot.position.x > middleX && robot.position.y < middleY {
            NE += 1
        } else if robot.position.x > middleX && robot.position.y > middleY {
            SE += 1
        } else {
//            print("in the middle")
        }
    }
    print("NW: \(NW), SW: \(SW), SE: \(SE), NE: \(NE))")
    return NW * SW * SE * NE
}

func day14_2024_A() throws -> Int {
    let lines = try FileReader(filename: "day14_2024_input").getLines()
    var robots = try lines.map { try parseLine($0) }
    let maxX = 101
    let maxY = 103
//    let map = initializeMap(withRobots: robots)
    (0..<100).forEach { _ in
        robots = blink(robots: robots, maxX: maxX, maxY: maxY)
    }
    return safetyFactor(robots: robots, maxX: maxX, maxY: maxY)
}

// MARK: - Part B

private func isEasterEgg(robots: [Robot], maxX: Int, maxY: Int) -> Bool {

    let map = initializeMap(withRobots: robots)
    var keepComputing = true
    (0...(map.maxY)).forEach { y in
        guard keepComputing else { return }
        (0...(map.maxX)).forEach { x in
            guard keepComputing else { return }
            guard let cell = map[Position(x: x, y: y)] else { return }
            if cell.robots.count > 1 {
                keepComputing = false
                return
            }
        }
    }
    return keepComputing
}

func day14_2024_B() throws -> Int {
    let lines = try FileReader(filename: "day14_2024_input").getLines()
    var robots = try lines.map { try parseLine($0) }
    let maxX = 101
    let maxY = 103
//    let map = initializeMap(withRobots: robots)
    var result: Int?
    var i = 1
    while result == nil {
        robots = blink(robots: robots, maxX: maxX, maxY: maxY)
        if isEasterEgg(robots: robots, maxX: maxX, maxY: maxY) {
            result = i
        }
        i += 1
    }
    // 6378 too high
    return i
}
