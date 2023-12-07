//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private enum Card: String, CaseIterable, Comparable {
    static func < (lhs: Card, rhs: Card) -> Bool {
        return lhs.value < rhs.value
    }
    
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "T"
    case jack = "J"
    case queen = "Q"
    case king = "K"
    case ace = "A"

    init(string: String) throws {
        switch string {
        case "2":
            self = .two
        case "3":
            self = .three
        case "4":
            self = .four
        case "5":
            self = .five
        case "6":
            self = .six
        case "7":
            self = .seven
        case "8":
            self = .eight
        case "9":
            self = .nine
        case "T":
            self = .ten
        case "J":
            self = .jack
        case "Q":
            self = .queen
        case "K":
            self = .king
        case "A":
            self = .ace
        default:
            throw AoCError.wrongFormat
        }
    }

    var value: Int {
        switch self {
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        case .ten: return 10
        case .jack: return 11
        case .queen: return 12
        case .king: return 13
        case .ace: return 14
        }
    }
}

private class Hand: Comparable, CustomStringConvertible {
    static func == (lhs: Hand, rhs: Hand) -> Bool {
        return lhs.cards == rhs.cards
        && lhs.bid == rhs.bid
    }

    let cards: [Card]
    let bid: Int

    var buckets = [Card: Int]()
    var filledBucketsCount: Int = 0
    var maxFilledBucket: Int {
        buckets.values.max()!
    }

    static func < (lhs: Hand, rhs: Hand) -> Bool {
        if lhs.filledBucketsCount < rhs.filledBucketsCount {
            return false
        }
        if lhs.filledBucketsCount > rhs.filledBucketsCount {
            return true
        }
        let (leftMax, rightMax) = (lhs.maxFilledBucket, rhs.maxFilledBucket)
        if leftMax != rightMax {
            return leftMax < rightMax
        }
        let tuple = lhs.cards.enumerated().first { (index, element) in
            lhs.cards[index] != rhs.cards[index]
        }
        let leftCard = lhs.cards[tuple!.0]
        let rightCard = rhs.cards[tuple!.0]
        return leftCard < rightCard
    }

    init(cards: [Card], bid: Int) {
        self.cards = cards
        self.bid = bid
        computeBuckets()
    }

    private func computeBuckets() {
        cards.forEach { card in
            let current = buckets[card] ?? 0
            buckets[card] = current + 1
        }
        filledBucketsCount = buckets.values.filter { $0 > 0 }.count
    }

    var description: String {
        return cards.map { $0.rawValue }.joined()
    }
}

private func parseLine(_ line: String) throws -> Hand {
    let components = line.components(separatedBy: CharacterSet.whitespaces)
    let cards = try components[0].map { try Card(string: String($0)) }
    let bid = Int(components[1])!
    return Hand(cards: cards, bid: bid)
}

func day7_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day7_2023_input").getLines()
    let hands = try lines.map(parseLine(_:))
    let sortedHands = hands.sorted()
    let values = sortedHands.enumerated().map { (index, hand) in
        return (index + 1) * hand.bid
    }
    return values.reduce(0, +)
}

// MARK: - Part 2

private enum BCard: String, CaseIterable, Comparable {
    static func < (lhs: BCard, rhs: BCard) -> Bool {
        return lhs.value < rhs.value
    }

    case joker = "J"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "T"
    case queen = "Q"
    case king = "K"
    case ace = "A"

    init(string: String) throws {
        switch string {
        case "J":
            self = .joker
        case "2":
            self = .two
        case "3":
            self = .three
        case "4":
            self = .four
        case "5":
            self = .five
        case "6":
            self = .six
        case "7":
            self = .seven
        case "8":
            self = .eight
        case "9":
            self = .nine
        case "T":
            self = .ten
        case "Q":
            self = .queen
        case "K":
            self = .king
        case "A":
            self = .ace
        default:
            throw AoCError.wrongFormat
        }
    }

    var value: Int {
        switch self {
        case .joker: return 1
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        case .ten: return 10
        case .queen: return 12
        case .king: return 13
        case .ace: return 14
        }
    }
}

private class BHand: Comparable, CustomStringConvertible {
    static func == (lhs: BHand, rhs: BHand) -> Bool {
        return lhs.cards == rhs.cards
        && lhs.bid == rhs.bid
    }

    let cards: [BCard]
    let bid: Int

    var buckets = [BCard: Int]()
    var filledBucketsCount: Int {
        let filled = buckets.keys.filter { $0 != .joker }.map { buckets[$0] != 0 ? 1 : 0 }.reduce(0, +)
        // Case JJJJJ
        return filled > 0 ? filled : 1
    }
    var maxFilledBucket: Int {
        let fill = buckets.keys.filter { $0 != .joker }.compactMap { buckets[$0] }.max() ?? 0
        let jokers = buckets[.joker] ?? 0
        return fill + jokers
    }

    static func < (lhs: BHand, rhs: BHand) -> Bool {
        if lhs.filledBucketsCount < rhs.filledBucketsCount {
            return false
        }
        if lhs.filledBucketsCount > rhs.filledBucketsCount {
            return true
        }
        let (leftMax, rightMax) = (lhs.maxFilledBucket, rhs.maxFilledBucket)
        if leftMax != rightMax {
            return leftMax < rightMax
        }
        let tuple = lhs.cards.enumerated().first { (index, element) in
            lhs.cards[index] != rhs.cards[index]
        }
        let leftCard = lhs.cards[tuple!.0]
        let rightCard = rhs.cards[tuple!.0]
        return leftCard < rightCard
    }

    init(cards: [BCard], bid: Int) {
        self.cards = cards
        self.bid = bid
        computeBuckets()
    }

    private func computeBuckets() {
        cards.forEach { card in
            let current = buckets[card] ?? 0
            buckets[card] = current + 1
        }
    }

    var description: String {
        return cards.map { $0.rawValue }.joined()
    }
}

private func parseLineSecondPart(_ line: String) throws -> BHand {
    let components = line.components(separatedBy: CharacterSet.whitespaces)
    let cards = try components[0].map { try BCard(string: String($0)) }
    let bid = Int(components[1])!
    return BHand(cards: cards, bid: bid)
}

func day7_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day7_2023_input").getLines()
    let hands = try lines.map(parseLineSecondPart(_:))
    print(hands)
    let sortedHands = hands.sorted()
    print(sortedHands)
    let values = sortedHands.enumerated().map { (index, hand) in
        return (index + 1) * hand.bid
    }
    return values.reduce(0, +)
}
