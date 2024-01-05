//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation
import CryptoKit

// courtesy of https://stackoverflow.com/a/56578995/900937
private func md5(string: String) -> String {
    let digest = Insecure.MD5.hash(data: Data(string.utf8))

    return digest.map {
        String(format: "%02hhx", $0)
    }.joined()
}

func day4_2015_A() throws -> Int {
    let key = try FileReader(filename: "day4_2015_input").getLines()[0]
    var count = 0
    var hash = md5(string: key + "\(count)")
    while !hash.hasPrefix("00000") {
        count += 1
        hash = md5(string: key + "\(count)")
    }
    return count
}

func day4_2015_B() throws -> Int {
    let key = try FileReader(filename: "day4_2015_input").getLines()[0]
    var count = 0
    var hash = md5(string: key + "\(count)")
    while !hash.hasPrefix("000000") {
        count += 1
        hash = md5(string: key + "\(count)")
    }
    return count
}
