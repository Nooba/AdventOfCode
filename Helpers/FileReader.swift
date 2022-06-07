//
//  FileReader.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

struct FileReader {

    private let fileContent: String

    init(filename: String) throws {
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let bundleURL = URL(fileURLWithPath: "Inputs.bundle", relativeTo: currentDirectoryURL)

        guard let bundle = Bundle(url: bundleURL),
            let url = bundle.url(forResource: filename, withExtension: "txt") else {
            throw AoCError.fileNotFound
        }
        guard
            let input = FileManager.default.contents(atPath: url.path),
            let text = String(data: input, encoding: .utf8) else {
            throw AoCError.fileMissingData
        }
        fileContent = text
    }

    func getLines(filterEmptyLines: Bool = true) -> [String] {
        let content = fileContent.components(separatedBy: CharacterSet.newlines).map { $0.trimmingCharacters(in: .whitespaces) }
        guard filterEmptyLines else {
            return content
        }
        return content.filter { !$0.isEmpty }
    }

    func getGroupedLines() -> [[String]] {
        let content = fileContent.components(separatedBy: CharacterSet.newlines).map { $0.trimmingCharacters(in: .whitespaces) }
        let initialArray: [[String]] = [[]]
        let result = content.reduce(into: initialArray) { partialResult, next in
            var previous = partialResult.last ?? []
            guard !next.isEmpty else {
                partialResult.append([])
                return
            }
            previous.append(next)
            partialResult[partialResult.count-1] = previous
        }
        return result.dropLast()
    }

}
