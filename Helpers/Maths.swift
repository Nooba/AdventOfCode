//
//  Maths.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 08/12/2023.
//

import Foundation

// GCD of two numbers:
func gcd(_ a: Int, _ b: Int) -> Int {
    var (a, b) = (a, b)
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return abs(a)
}

// GCD of a vector of numbers:
func gcd(_ vector: [Int]) -> Int {
    return vector.reduce(0, gcd)
}

// LCM of two numbers:
func lcm(a: Int, b: Int) -> Int {
    return (a / gcd(a, b)) * b
}

// LCM of a vector of numbers:
func lcm(_ vector : [Int]) -> Int {
    return vector.reduce(1, lcm)
}
