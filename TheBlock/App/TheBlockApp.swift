//
//  TheBlockApp.swift
//  TheBlock
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import SwiftUI

@main
struct TheBlockApp: App {
    private let repository: VehicleRepository = BundledVehicleRepository()
    private let biddingEngine = BiddingEngine()
    private let ticker = Ticker()

    var body: some Scene {
        WindowGroup {
            InventoryView(
                repository: repository,
                biddingEngine: biddingEngine,
                ticker: ticker
            )
            .task { await ticker.start() }
        }
    }
}
