//
//  InventoryFilters.swift
//  TheBlock
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import Foundation

struct InventoryFilters: Equatable {
    var auctionStatus: AuctionStatusFilter?
    var maxBid: Int?
    var cleanTitleOnly = false

    var activeCount: Int {
        [auctionStatus != nil, maxBid != nil, cleanTitleOnly].filter { $0 }.count
    }

    var isEmpty: Bool { activeCount == 0 }

    func matches(vehicle: Vehicle, displayedBid: Decimal, timing: AuctionTiming) -> Bool {
        if let auctionStatus, !auctionStatus.matches(timing) { return false }
        if let maxBid, displayedBid > Decimal(maxBid) { return false }
        if cleanTitleOnly && vehicle.titleStatus.lowercased() != "clean" { return false }
        return true
    }
}

enum AuctionStatusFilter: String, CaseIterable, Identifiable {
    case live = "Live now"
    case upcoming = "Starting soon"
    case ended = "Ended"

    var id: String { rawValue }

    func matches(_ timing: AuctionTiming) -> Bool {
        switch (self, timing) {
        case (.live, .live), (.upcoming, .upcoming), (.ended, .ended):
            return true
        default:
            return false
        }
    }
}
