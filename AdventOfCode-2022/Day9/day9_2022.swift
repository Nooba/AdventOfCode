//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

private struct BoardSlot: Hashable {
    let x: Int
    let y: Int
}

private func moveTail(headX: Int, headY: Int, tailX: Int, tailY: Int) -> (Int, Int) {
    if abs(headX - tailX) <= 1 && abs(headY - tailY) <= 1 {
        // Don’t move
//        print(tailX, tailY)
        return (tailX, tailY)
    }
    if abs(headX - tailX) == 0 {
        // Move Y
        let newTailY = tailY > headY ? tailY - 1 : tailY + 1
//        print(tailX, newTailY)
        return (tailX, newTailY)
    } else if abs(headY - tailY) == 0 {
        // Move X
        let newTailX = tailX > headX ? tailX - 1 : tailX + 1
//        print(newTailX, tailY)
        return (newTailX, tailY)
    } else {
        // Move both
        let newTailY = tailY > headY ? tailY - 1 : tailY + 1
        let newTailX = tailX > headX ? tailX - 1 : tailX + 1
//        print(newTailX, newTailY)
        return (newTailX, newTailY)
    }
}

func day9_2022_A() throws -> Int {
    var currentHeadX = 0
    var currentHeadY = 0
    var currentTailX = 0
    var currentTailY = 0
    let lines = try FileReader(filename: "day9_2022_input").getLines()
    var visitedBoard = Set<BoardSlot>()
    visitedBoard.insert(BoardSlot(x: currentTailX, y: currentTailY))
    try lines.forEach { line in
        let comps = line.components(separatedBy: " ")
        let (direction, valueString) = (comps[0], comps[1])
        let value = Int(valueString)!
        switch direction {
        case "R":
            for _ in (1...value) {
                currentHeadX += 1
                (currentTailX, currentTailY) = moveTail(headX: currentHeadX, headY: currentHeadY, tailX: currentTailX, tailY: currentTailY)
                visitedBoard.insert(BoardSlot(x: currentTailX, y: currentTailY))
            }
        case "U":
            for _ in (1...value) {
                currentHeadY += 1
                (currentTailX, currentTailY) = moveTail(headX: currentHeadX, headY: currentHeadY, tailX: currentTailX, tailY: currentTailY)
                visitedBoard.insert(BoardSlot(x: currentTailX, y: currentTailY))
            }
        case "D":
            for _ in (1...value) {
                currentHeadY -= 1
                (currentTailX, currentTailY) = moveTail(headX: currentHeadX, headY: currentHeadY, tailX: currentTailX, tailY: currentTailY)
                visitedBoard.insert(BoardSlot(x: currentTailX, y: currentTailY))
            }
        case "L":
            for _ in (1...value) {
                currentHeadX -= 1
                (currentTailX, currentTailY) = moveTail(headX: currentHeadX, headY: currentHeadY, tailX: currentTailX, tailY: currentTailY)
                visitedBoard.insert(BoardSlot(x: currentTailX, y: currentTailY))
            }
        default:
            throw AoCError.wrongFormat
        }
    }
    return visitedBoard.count
}

private struct Knot {
    var x: Int
    var y: Int
}

func day9_2022_B() throws -> Int {
    var rope: [Knot] = []
    for _ in (1...10) { rope.append(Knot(x: 0, y: 0)) }
    let lines = try FileReader(filename: "day9_2022_input").getLines()
    var visitedBoard = Set<BoardSlot>()
    visitedBoard.insert(BoardSlot(x: 0, y: 0))
    try lines.forEach { line in
        let comps = line.components(separatedBy: " ")
        let (direction, valueString) = (comps[0], comps[1])
        let value = Int(valueString)!
        switch direction {
        case "R":
            for _ in (1...value) {
                var head = rope[0]
                head.x += 1
                rope[0] = head
                for index in (1..<10) {
                    var knot = rope[index]
                    guard index > 0 else { return }
                    let previous = rope[index - 1]
                    let (newX, newY) = moveTail(headX: previous.x, headY: previous.y, tailX: knot.x, tailY: knot.y)
                    knot.x = newX
                    knot.y = newY
                    rope[index] = knot
                }
                visitedBoard.insert(BoardSlot(x: rope[9].x, y: rope[9].y))
            }
        case "U":
            for _ in (1...value) {
                var head = rope[0]
                head.y += 1
                rope[0] = head
                for index in (1..<10) {
                    var knot = rope[index]
                    guard index > 0 else { return }
                    let previous = rope[index - 1]
                    let (newX, newY) = moveTail(headX: previous.x, headY: previous.y, tailX: knot.x, tailY: knot.y)
                    knot.x = newX
                    knot.y = newY
                    rope[index] = knot
                }
                visitedBoard.insert(BoardSlot(x: rope[9].x, y: rope[9].y))
            }
        case "D":
            for _ in (1...value) {
                var head = rope[0]
                head.y -= 1
                rope[0] = head
                for index in (1..<10) {
                    var knot = rope[index]
                    guard index > 0 else { return }
                    let previous = rope[index - 1]
                    let (newX, newY) = moveTail(headX: previous.x, headY: previous.y, tailX: knot.x, tailY: knot.y)
                    knot.x = newX
                    knot.y = newY
                    rope[index] = knot
                }
                visitedBoard.insert(BoardSlot(x: rope[9].x, y: rope[9].y))
            }
        case "L":
            for _ in (1...value) {
                var head = rope[0]
                head.x -= 1
                rope[0] = head
                for index in (1..<10) {
                    var knot = rope[index]
                    guard index > 0 else { return }
                    let previous = rope[index - 1]
                    let (newX, newY) = moveTail(headX: previous.x, headY: previous.y, tailX: knot.x, tailY: knot.y)
                    knot.x = newX
                    knot.y = newY
                    rope[index] = knot
                }
                visitedBoard.insert(BoardSlot(x: rope[9].x, y: rope[9].y))
            }
        default:
            throw AoCError.wrongFormat
        }
    }
    return visitedBoard.count
}
