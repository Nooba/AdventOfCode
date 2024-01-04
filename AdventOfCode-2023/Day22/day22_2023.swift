//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private typealias Position = (x: Int, y: Int, z: Int)

private class Brick: Equatable, Hashable {
    static func == (lhs: Brick, rhs: Brick) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: UUID = UUID()
    var cubes: [Position]

    init(cubes: [Position]) {
        self.cubes = cubes
    }

    var minZ: Int {
        return cubes.map(\.z).min()!
    }

    func cubesBelow(brick: Brick) -> [Position] {
        guard self != brick else { return [] }
        let belowCubes = cubes.filter { cube in
            let filtered = brick.cubes.first { upperBrick in
                upperBrick.x == cube.x && upperBrick.y == cube.y && upperBrick.z > cube.z
            }
            return filtered != nil
        }
        return belowCubes
    }

    func moveDown(targetZ: Int) {
        let minZ = cubes.map(\.z).min() ?? 1
        let offset = minZ - targetZ
        cubes = cubes.map { cube in
            return (cube.x, cube.y, cube.z - offset)
        }
    }

    func isActivelySupporting(brick: Brick) -> Bool {
        guard self != brick else { return false }
        guard let belowCubesMaxZ = cubesBelow(brick: brick).map(\.z).max(),
              let upperBrickMinZ = brick.cubes.map(\.z).min() else {
            return false
        }
        return belowCubesMaxZ + 1 == upperBrickMinZ
    }
}

private func parse(_ line: String) throws -> Brick {
    let components = line.components(separatedBy: "~")
    let left = components[0].components(separatedBy: ",").map { Int($0)! }
    let right = components[1].components(separatedBy: ",").map { Int($0)! }
    let positions = (left[0]...right[0]).flatMap { x in
        return (left[1]...right[1]).flatMap { y in
            return (left[2]...right[2]).map { z in
                return Position(x, y, z)
            }
        }
    }
    return Brick(cubes: positions)
}

private class Space {
    var bricks: [Brick]

    init(bricks: [Brick]) {
        self.bricks = bricks.sorted(by: { left, right in
            left.minZ < right.minZ
        })
    }

    func letBricksRest() {
        bricks = bricks.map { currentToDescend in
            // find top Z of bricks "below" current one
            let maxZ = bricks.compactMap { brickToCheck in
                brickToCheck.cubesBelow(brick: currentToDescend).map(\.z).max()
            }.max()
            // move it down accordingly
            if let maxZ {
//                print("moving down by \(maxZ)")
                currentToDescend.moveDown(targetZ: maxZ + 1)
            }
            return currentToDescend
        }
    }

    func findDispensableBricks() -> [Brick] {
        bricks.filter { testDispensable in
            let supportedBricks = bricks.filter { supportedBrick in
                testDispensable.isActivelySupporting(brick: supportedBrick)
            }
            // Remove any that has any other support than currently tested
            let filteredSupported = supportedBricks.filter { supportedBrick in
                return bricks.first { secondSupport in
                    guard secondSupport != testDispensable else { return false }
                    return secondSupport.isActivelySupporting(brick: supportedBrick)
                } == nil
            }
            return filteredSupported.count == 0
        }
    }

    func findNecessaryBricks() -> [Brick] {
        var result = Set<Brick>()
        bricks.forEach { brick in
            let supportingBrick = bricks.filter { supportingBrick in
                supportingBrick.isActivelySupporting(brick: brick)
            }
            if supportingBrick.count == 1 {
                result.insert(supportingBrick[0])
            }
        }
        return Array(result)
    }
}

func day22_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day22_2023_input").getLines()
    let bricks = try lines.map(parse(_:))
    let space = Space(bricks: bricks)
    space.letBricksRest()
    let dispensable = space.findDispensableBricks()
    let necessary = space.findNecessaryBricks()
    return bricks.count - necessary.count
    // Wrong answer
    // 427 -> Too low
    // 722 -> Too high
}

// MARK: - Part 2

func day22_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day21_2023_example").getLines()
    return -1
}
