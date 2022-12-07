//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

private class Directory: CustomDebugStringConvertible {
    let name: String
    let parent: Directory?
    var directories: [Directory]
    var files: [File]

    var size: Int {
        let directoriesSize = directories.reduce(into: 0) { partialResult, directory in
            partialResult += directory.size
        }
        let filesSize = files.reduce(into: 0) { partialResult, file in
            partialResult += file.size
        }
        return directoriesSize + filesSize
    }

    init(name: String, parent: Directory?) {
        self.name = name
        self.parent = parent
        directories = []
        files = []
    }

    var debugDescription: String {
        return "Name: \(name)\nSubdirs: \(directories)\nFiles: \(files)\n"
    }
}

private struct File: CustomDebugStringConvertible {
    let name: String
    let size: Int

    var debugDescription: String {
        return "\(name): \(size)"
    }
}

private func parseFile(_ line: String) throws -> File {
    let capturePattern = #"(\d+) (.*)"#
    let captureRegex = try! NSRegularExpression(
        pattern: capturePattern,
        options: []
    )
    let lineRange = NSRange(line.startIndex..<line.endIndex, in: line)
    let matches = captureRegex.matches(in: line, options: [], range: lineRange)
    guard let match = matches.first else {
        throw AoCError.wrongFormat
    }
    var actions: [String] = []
    for rangeIndex in 0..<match.numberOfRanges {
        let matchRange = match.range(at: rangeIndex)

        // Ignore matching the entire username string
        if matchRange == lineRange { continue }

        // Extract the substring matching the capture group
        if let substringRange = Range(matchRange, in: line) {
            let capture = String(line[substringRange])
            actions.append(capture)
        }
    }
    return File(name: actions[1], size: Int(actions[0])!)
}

func day7_2022_A() throws -> Int {
    let lines = try FileReader(filename: "day7_2022_input").getLines()
    var currentDirectory: Directory? = Directory(name: "/", parent: nil)
    var directories: [Directory] = [currentDirectory!]
    try lines.forEach { line in
        if line == "$ cd .." {
            currentDirectory = currentDirectory?.parent
            return
        }
        if line.hasPrefix("$ cd ") {
            let newDirName = String(line.suffix(from: line.index(line.startIndex, offsetBy: 5)))
            let newDir = Directory(name: newDirName, parent: currentDirectory)
            directories.append(newDir)
            currentDirectory?.directories.append(newDir)
            currentDirectory = newDir
            return
        }
        if line == "$ ls" {
            return
        }
        if line.hasPrefix("dir ") {
            return
        }
        let newFile = try parseFile(line)
        currentDirectory?.files.append(newFile)
    }
    return directories.map { $0.size }.filter { $0 <= 100000 }.reduce(0, +)
}

func day7_2022_B() throws -> Int {
    let totalSpace = 70000000
    let targetUnused = 30000000
    let lines = try FileReader(filename: "day7_2022_input").getLines()
    let home = Directory(name: "/", parent: nil)
    var currentDirectory: Directory? = home
    var directories: [Directory] = [home]
    try lines.forEach { line in
        if line == "$ cd .." {
            currentDirectory = currentDirectory?.parent
            return
        }
        if line.hasPrefix("$ cd ") {
            let newDirName = String(line.suffix(from: line.index(line.startIndex, offsetBy: 5)))
            let newDir = Directory(name: newDirName, parent: currentDirectory)
            directories.append(newDir)
            currentDirectory?.directories.append(newDir)
            currentDirectory = newDir
            return
        }
        if line == "$ ls" {
            return
        }
        if line.hasPrefix("dir ") {
            return
        }
        let newFile = try parseFile(line)
        currentDirectory?.files.append(newFile)
    }
    let currentUnused = totalSpace - home.size
    let minimalSpaceToFree = targetUnused - currentUnused
    return directories.map { $0.size }.sorted().first { $0 > minimalSpaceToFree }!
}
