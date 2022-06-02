//
//  BinaryUtils.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 02/06/2022.
//

import Foundation

extension Int {
    static func fromBinary(string: String) throws -> Int {
        guard let int = Int(string, radix: 2) else {
            throw AoCError.wrongFormat
        }
        return int
    }
}
