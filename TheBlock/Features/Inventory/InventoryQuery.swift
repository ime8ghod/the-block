//
//  InventoryQuery.swift
//  TheBlock
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import Foundation

enum InventorySort: String, CaseIterable, Identifiable {
    case endingSoon = "Ending soon"
    case lowestBid = "Lowest bid"
    case newestYear = "Newest year"
    case bestCondition = "Best condition"

    var id: String { rawValue }
}

struct InventoryRow: Identifiable {
    let index: Int
    let vehicle: Vehicle

    var id: String { vehicle.id }
}

struct InventoryQuery {
    // Keeping query logic here keeps InventoryView focused on screen state and navigation.
    var searchText: String
    var filters: InventoryFilters
    var sort: InventorySort
    var now: Date
    var auctionAnchor: Date
    var biddingEngine: BiddingEngine

    func rows(from vehicles: [Vehicle]) -> [InventoryRow] {
        let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let rows = vehicles.enumerated()
            .map { InventoryRow(index: $0.offset, vehicle: $0.element) }
            .filter { row in
                guard row.vehicle.matchesInventorySearch(search) else { return false }

                return filters.matches(
                    vehicle: row.vehicle,
                    displayedBid: biddingEngine.displayedCurrentBid(for: row.vehicle),
                    timing: normalizedTiming(for: row.index, now: now, anchor: auctionAnchor)
                )
            }

        return rows.sorted(by: comesBefore)
    }

    private func comesBefore(_ lhs: InventoryRow, _ rhs: InventoryRow) -> Bool {
        switch sort {
        case .endingSoon:
            let left = timingRank(for: lhs.index)
            let right = timingRank(for: rhs.index)
            if left.group != right.group { return left.group < right.group }
            if left.seconds != right.seconds { return left.seconds < right.seconds }
            return lhs.index < rhs.index
        case .lowestBid:
            let left = biddingEngine.displayedCurrentBid(for: lhs.vehicle)
            let right = biddingEngine.displayedCurrentBid(for: rhs.vehicle)
            if left != right { return left < right }
            return lhs.index < rhs.index
        case .newestYear:
            if lhs.vehicle.year != rhs.vehicle.year { return lhs.vehicle.year > rhs.vehicle.year }
            return lhs.index < rhs.index
        case .bestCondition:
            if lhs.vehicle.conditionGrade != rhs.vehicle.conditionGrade { return lhs.vehicle.conditionGrade > rhs.vehicle.conditionGrade }
            return lhs.index < rhs.index
        }
    }

    private func timingRank(for index: Int) -> (group: Int, seconds: TimeInterval) {
        switch normalizedTiming(for: index, now: now, anchor: auctionAnchor) {
        case .live(let timeLeft):
            return (0, timeLeft)
        case .upcoming(let startsIn):
            return (1, startsIn)
        case .ended:
            return (2, .greatestFiniteMagnitude)
        }
    }
}

private extension Vehicle {
    func matchesInventorySearch(_ query: String) -> Bool {
        query.isEmpty
            || String(year).contains(query)
            || make.lowercased().contains(query)
            || model.lowercased().contains(query)
            || trim.lowercased().contains(query)
            || vin.lowercased().contains(query)
            || city.lowercased().contains(query)
    }
}
