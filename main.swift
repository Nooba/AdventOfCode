//
//  main.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

let start = Date()
let result = try day15_2024_B()
let finish = Date()
let durationString = String(format: "%.3f", start.distance(to: finish))
print("Result: \(result), computed in \(durationString) seconds")
