//
//  BiddingEngine.swift
//  TheBlock
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import Foundation
import Observation

enum BidStatus: Equatable {
    case leading
    case outbid
}

struct LiveBidState: Equatable {
    var status: BidStatus
    var myBid: Decimal
    var bidsPlaced: Int = 0
}

@MainActor
@Observable
final class BiddingEngine {
    // Session-only state for the prototype. A real app would persist this server-side.
    private(set) var liveStates: [String: LiveBidState] = [:]
    private var purchasedBidIncrements: [String: Int] = [:]

    func state(for vehicleID: String) -> LiveBidState? {
        liveStates[vehicleID]
    }

    func isPurchased(_ vehicle: Vehicle) -> Bool {
        purchasedBidIncrements[vehicle.id] != nil
    }

    func displayedCurrentBid(for vehicle: Vehicle) -> Decimal {
        if isPurchased(vehicle), let buyNowPrice = vehicle.buyNowPrice {
            return buyNowPrice
        }
        if let state = liveStates[vehicle.id], state.status == .leading {
            return state.myBid
        }
        return vehicle.currentBid ?? vehicle.startingBid
    }

    func displayedBidCount(for vehicle: Vehicle) -> Int {
        (vehicle.bidCount ?? 0)
        + (liveStates[vehicle.id]?.bidsPlaced ?? 0)
        + (purchasedBidIncrements[vehicle.id] ?? 0)
    }

    func minimumNextBid(for vehicle: Vehicle) -> Int {
        let current = displayedCurrentBid(for: vehicle)
        let currentInt = NSDecimalNumber(decimal: current).intValue
        return ((currentInt + 499) / 500 * 500) + 500
    }

    func canPlaceBid(_ amount: Int, on vehicle: Vehicle) -> Bool {
        !isPurchased(vehicle) && amount >= minimumNextBid(for: vehicle)
    }

    func placeBid(_ amount: Int, on vehicle: Vehicle) {
        guard canPlaceBid(amount, on: vehicle) else { return }
        saveLeadingBid(amount, on: vehicle)
    }

    func placeBuyNow(on vehicle: Vehicle) {
        guard let buyNowPrice = vehicle.buyNowPrice else { return }
        guard !isPurchased(vehicle), buyNowPrice > displayedCurrentBid(for: vehicle) else { return }

        // Buy Now is not an active bid anymore, so it should not show in My bids.
        let previousUserBidCount = liveStates[vehicle.id]?.bidsPlaced ?? 0
        liveStates[vehicle.id] = nil
        purchasedBidIncrements[vehicle.id] = previousUserBidCount + 1
    }

    private func saveLeadingBid(_ amount: Int, on vehicle: Vehicle) {
        let previousCount = liveStates[vehicle.id]?.bidsPlaced ?? 0
        liveStates[vehicle.id] = LiveBidState(
            status: .leading,
            myBid: Decimal(amount),
            bidsPlaced: previousCount + 1
        )
    }

    func seedDemoBids(using vehicles: [Vehicle]) {
        guard liveStates.isEmpty, purchasedBidIncrements.isEmpty, vehicles.count >= 2 else { return }

        let leadingVehicle = vehicles[0]
        liveStates[leadingVehicle.id] = LiveBidState(
            status: .leading,
            myBid: leadingVehicle.currentBid ?? leadingVehicle.startingBid
        )

        let outbidVehicle = vehicles[1]
        let referencePrice = outbidVehicle.currentBid ?? outbidVehicle.startingBid
        liveStates[outbidVehicle.id] = LiveBidState(
            status: .outbid,
            myBid: referencePrice - 200
        )
    }
}
