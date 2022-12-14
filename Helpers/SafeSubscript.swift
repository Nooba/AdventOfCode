//
//  SafeSubscript.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 10/06/2022.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
