//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

private struct Game {
    struct Draw {
        let blues: Int
        let reds: Int
        let greens: Int
    }

    let number: Int
    let draws: [Draw]

    func isValid(totalBlues: Int, totalReds: Int, totalGreens: Int) -> Bool {
        return draws.allSatisfy { draw in
            draw.blues <= totalBlues
            && draw.reds <= totalReds
            && draw.greens <= totalGreens
        }
    }
}

private func parseLine(_ line: String) throws -> Int {
    let game = try parseRegexp(line, capturePattern: #"Game (\d+): (.*)"#) { actions in
        let drawsStrings = actions.last!.components(separatedBy: ";")
        let draws = try drawsStrings.map { try parseDraw($0) }
        return Game(number: Int(actions.first!)!, draws: draws)
    }
    return game.isValid(totalBlues: totalBlues, totalReds: totalReds, totalGreens: totalGreens)
    ? game.number
    : 0
}

private func parseDraw(_ draw: String) throws -> Game.Draw {
    let redCount = try? parseRegexp(draw, capturePattern: #"(\d+) red"#) {
        return $0[safe: 1].map { Int($0)! } ?? 0
    }
    let greenCount = try? parseRegexp(draw, capturePattern: #"(\d+) green"#) {
        return $0[safe: 1].map { Int($0)! } ?? 0
    }
    let blueCount = try? parseRegexp(draw, capturePattern: #"(\d+) blue"#) {
        return $0[safe: 1].map { Int($0)! } ?? 0
    }
    return Game.Draw(blues: blueCount ?? 0, reds: redCount ?? 0, greens: greenCount ?? 0)
}

private let totalReds = 12
private let totalGreens = 13
private let totalBlues = 14

func day2_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day2_2023_input").getLines()
    let numbers = try lines.map(parseLine(_:))
    return numbers.reduce(0, +)
}

private func parseLineSecondPart(_ line: String) throws -> Int {
    let game = try parseRegexp(line, capturePattern: #"Game (\d+): (.*)"#) { actions in
        let drawsStrings = actions.last!.components(separatedBy: ";")
        let draws = try drawsStrings.map { try parseDraw($0) }
        return Game(number: Int(actions.first!)!, draws: draws)
    }
    return gamePower(game)
}

private func gamePower(_ game: Game) -> Int {
    guard let gameBlues = game.draws.map ({ $0.blues }).max(),
          let gameReds = game.draws.map ({ $0.reds }).max(),
          let gameGreens = game.draws.map ({ $0.greens }).max() else {
        return 0
    }
    return gameBlues * gameReds * gameGreens
}

func day2_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day2_2023_input").getLines()
    let numbers = try lines.map(parseLineSecondPart(_:))
    return numbers.reduce(0, +)
}
