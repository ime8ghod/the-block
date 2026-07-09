//
//  Ticker.swift
//  TheBlock
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import Foundation
import Observation

@MainActor
@Observable
final class Ticker {
    // One shared clock is enough for countdowns in this prototype.
    private(set) var now: Date = .now

    func start() async {
        while !Task.isCancelled {
            now = .now
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }
}
