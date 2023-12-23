//
//  day1.swift
//  AdventOfCode
//
//  Created by Edouard Siegel on 01/06/2022.
//

import Foundation

// MARK: - Part 1

private struct Pulse: CustomStringConvertible {
    enum PulseType: String {
        case low
        case high
    }

    let type: PulseType
    let destination: String
    let origin: String

    var description: String {
        "from \(origin) -\(type.rawValue)-> \(destination)"
    }
}

private protocol Module {
    var name: String { get }
    var destinations: [String] { get }
    func process(pulse: Pulse, from name: String)
}

private class FlipFlopModule: Module {
    var name: String
    private var isOn = false

    let destinations: [String]

    init(name: String, destinations: [String]) {
        self.name = name
        self.destinations = destinations
    }

    func process(pulse: Pulse, from name: String) {
        guard pulse.type == .low else { return }
        isOn.toggle()
        switch isOn {
        case true:
            highPulseCount += destinations.count
            destinations.forEach { pulsesQueue.append(Pulse(type: .high, destination: $0, origin: self.name)) }
        case false:
            lowPulseCount += destinations.count
            destinations.forEach { pulsesQueue.append(Pulse(type: .low, destination: $0, origin: self.name)) }
        }
    }
}

private class ConjunctionModule: Module {
    var name: String
    var inputs: [String: Pulse.PulseType]

    let destinations: [String]

    init(name: String, destinations: [String]) {
        self.name = name
        self.destinations = destinations
        inputs = [:]
    }

    func process(pulse: Pulse, from name: String) {
        inputs[name] = pulse.type
        guard inputs.values.allSatisfy ({ $0 == .high }) else {
            highPulseCount += destinations.count
            destinations.forEach { pulsesQueue.append(Pulse(type: .high, destination: $0, origin: self.name)) }
            return
        }
        lowPulseCount += destinations.count
        destinations.forEach { pulsesQueue.append(Pulse(type: .low, destination: $0, origin: self.name)) }
    }
}

private class BroadcastModule: Module { 
    var name: String
    let destinations: [String]

    init(name: String, destinations: [String]) {
        self.name = name
        self.destinations = destinations
    }

    func process(pulse: Pulse, from name: String) {
        switch pulse.type {
        case .low:
            lowPulseCount += destinations.count
        case .high:
            highPulseCount += destinations.count
        }
        destinations.forEach { pulsesQueue.append(Pulse(type: pulse.type, destination: $0, origin: self.name)) }
    }
}

private class ButtonModule: Module {
    var name: String
    let destinations: [String] = ["broadcaster"]

    init(name: String) {
        self.name = name
    }

    func process(pulse: Pulse, from name: String) {
        lowPulseCount += destinations.count
        destinations.forEach { pulsesQueue.append(Pulse(type: .low, destination: $0, origin: self.name)) }
    }

    func tap() {
        let pulse = Pulse(type: .high, destination: "broadcaster", origin: "button")
        process(pulse: pulse, from: pulse.origin)
    }
}

//private var broadcaster: BroadcastModule!
private var button: ButtonModule!
private var modules: [String: Module] = [:]
private var pulsesQueue: [Pulse] = []
private var lowPulseCount = 0
private var highPulseCount = 0

private func parse(_ line: String) throws {
    let components = line.components(separatedBy: " -> ")
    let destinations = components[1].components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    if components[0] == "broadcaster" {
        modules["broadcaster"] = BroadcastModule(
            name: "broadcaster",
            destinations: destinations
        )
    } else if components[0].hasPrefix("%") {
        let name = String(components[0].dropFirst())
        modules[name] = FlipFlopModule(
            name: name,
            destinations: destinations
        )
    } else if components[0].hasPrefix("&") {
        let name = String(components[0].dropFirst())
        modules[name] = ConjunctionModule(
            name: name,
            destinations: destinations
        )
    } else {
        fatalError()
    }
}

private func setConjuctionModulesInputs() {
    let conjuctionModules = modules.values.compactMap { $0 as? ConjunctionModule }
    conjuctionModules.forEach { module -> Void in
        let name = module.name
        let inputs = modules.values
            .filter { $0.destinations.contains(name) }
            .reduce(into: [String:Pulse.PulseType]()) { partialResult, module in
                partialResult[module.name] = .low
            }
        module.inputs = inputs
    }
}

func day20_2023_A() throws -> Int {
    let lines = try FileReader(filename: "day20_2023_input").getLines()
    try lines.forEach(parse(_:))
    setConjuctionModulesInputs()
    button = ButtonModule(name: "button")
    (1...1000).forEach { _ in
        button.tap()
        while let nextPulse = pulsesQueue.first {
            modules[nextPulse.destination]?.process(pulse: nextPulse, from: nextPulse.origin)
            pulsesQueue = Array(pulsesQueue.dropFirst())
        }
    }
    return lowPulseCount * highPulseCount
}

// MARK: - Part 2

func day20_2023_B() throws -> Int {
    let lines = try FileReader(filename: "day20_2023_input").getLines()
    try lines.forEach(parse(_:))
    return -1
}
