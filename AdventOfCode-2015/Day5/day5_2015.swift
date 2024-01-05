//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

private func isNice(string: String) -> Bool {
    let releventVowels = Set<Character>(["a", "o", "e", "i", "u"])
    let forbiddenStringsRegex = #"(ab|cd|pq|xy)"#
    guard !string.contains(try! Regex(forbiddenStringsRegex)) else {
        return false
    }
    // Any letter, then that same letter again
    guard string.contains(try! Regex(#"(\w)\1"#)) else {
        return false
    }
    let set = Set<Character>(string)
    let usedVowels = set.intersection(releventVowels)
    guard !usedVowels.isEmpty else { return false }
    let vowelCount = usedVowels.reduce(into: 0) { partialResult, vowel in
        partialResult += (string.filter { $0 == vowel }.count)
    }
    return vowelCount >= 3
}

func day5_2015_A() throws -> Int {
    let lines = try FileReader(filename: "day5_2015_input").getLines()
    let result = lines.reduce(into: 0) { partialResult, string in
        partialResult += isNice(string: string) ? 1 : 0
    }
    return result
}

private func isTrulyNice(string: String) -> Bool {
    // Any letter pair, then something, then that same letter pair again
    guard string.contains(try! Regex(#"(\w\w).*\1"#)) else {
        return false
    }
    // Any letter, than exactly one letter, than the first letter again
    guard string.contains(try! Regex(#"(\w).\1"#)) else {
        return false
    }
    return true
}


func day5_2015_B() throws -> Int {
    let lines = try FileReader(filename: "day5_2015_input").getLines()
    let result = lines.reduce(into: 0) { partialResult, string in
        partialResult += isTrulyNice(string: string) ? 1 : 0
    }
    return result
}
